lib.versionCheck('Project-Sloth/ps-banking')
assert(lib.checkDependency('ox_lib', '3.20.0', true))

local framework = nil

if GetResourceState("es_extended") == "started" then
    framework = "ESX"
    ESX = exports["es_extended"]:getSharedObject()
elseif GetResourceState("qb-core") == "started" then
    framework = "QBCore"
    QBCore = exports["qb-core"]:GetCoreObject()
else
    return error(locale("no_framework_found"))
end

local function getPlayerIdentifier(player)
    if framework == "ESX" then
        return player.getIdentifier()
    elseif framework == "QBCore" then
        return player.PlayerData.citizenid
    end
end

local function getPlayerFromId(source)
    if framework == "ESX" then
        return ESX.GetPlayerFromId(source)
    elseif framework == "QBCore" then
        return QBCore.Functions.GetPlayer(source)
    end
end

local function getPlayerAccounts(player)
    if framework == "ESX" then
        return player.getAccount("bank").money
    elseif framework == "QBCore" then
        return player.PlayerData.money["bank"]
    end
end

local function getName(player)
    if framework == "ESX" then
        return player.getName()
    elseif framework == "QBCore" then
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end
end

lib.callback.register("ps-banking:server:getHistory", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    local result = MySQL.query.await('SELECT * FROM ps_banking_transactions WHERE identifier = ?', { identifier })
    return result
end)

lib.callback.register("ps-banking:server:deleteHistory", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    MySQL.query.await('DELETE FROM ps_banking_transactions WHERE identifier = ?', { identifier })
    return true
end)

lib.callback.register("ps-banking:server:payAllBills", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    local result = MySQL.query.await('SELECT SUM(amount) as total FROM ps_banking_bills WHERE identifier = ? AND isPaid = 0', { identifier })
    local totalAmount = result[1].total or 0
    local bankBalance = getPlayerAccounts(xPlayer)
    if tonumber(bankBalance) >= tonumber(totalAmount) then
        if framework == "ESX" then
            xPlayer.removeAccountMoney("bank", tonumber(totalAmount))
        elseif framework == "QBCore" then
            xPlayer.Functions.RemoveMoney("bank", tonumber(totalAmount))
        end
        MySQL.query.await('DELETE FROM ps_banking_bills WHERE identifier = ?', { identifier })
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:getWeeklySummary", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    local receivedResult = MySQL.query.await('SELECT SUM(amount) as totalReceived FROM ps_banking_transactions WHERE identifier = ? AND isIncome = ? AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)', { identifier, true })
    local totalReceived = receivedResult[1].totalReceived or 0
    local usedResult = MySQL.query.await('SELECT SUM(amount) as totalUsed FROM ps_banking_transactions WHERE identifier = ? AND isIncome = ? AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)', { identifier, false })
    local totalUsed = usedResult[1].totalUsed or 0
    return {
        totalReceived = totalReceived,
        totalUsed = totalUsed,
    }
end)

lib.callback.register("ps-banking:server:transferMoney", function(source, data)
    local xPlayer = getPlayerFromId(source)
    local targetPlayer = getPlayerFromId(data.id)
    local amount = tonumber(data.amount)

    if data.id == source and data.method == "id" then
        return false, locale("cannot_send_self_money")
    end

    if xPlayer and targetPlayer and amount > 0 then
        local xPlayerBalance = getPlayerAccounts(xPlayer)
        if xPlayerBalance >= amount then
            if data.method == "id" then
                if framework == "ESX" then
                    xPlayer.removeAccountMoney("bank", amount)
                    targetPlayer.addAccountMoney("bank", amount)
                elseif framework == "QBCore" then
                    xPlayer.Functions.RemoveMoney("bank", amount)
                    targetPlayer.Functions.AddMoney("bank", amount)
                end
                return true, locale("money_sent", amount, getName(targetPlayer))
            elseif data.method == "phone" then
                exports["lb-phone"]:AddTransaction(targetPlayer.identifier, amount,
                    locale("received_money", getName(xPlayer), amount))
                return true, locale("money_sent", amount, getName(targetPlayer))
            end
        else
            return false, locale("no_money")
        end
    else
        return false, locale("user_not_in_city")
    end
end)

local function logTransaction(identifier, description, accountName, amount, isIncome)
    MySQL.insert.await('INSERT INTO ps_banking_transactions (identifier, description, type, amount, date, isIncome) VALUES (?, ?, ?, ?, NOW(), ?)', { identifier, description, accountName, amount, isIncome })
end

RegisterNetEvent("ps-banking:server:logClient", function(account, moneyData)
    if account.name ~= "bank" then
        return
    end

    local src = source
    local xPlayer = getPlayerFromId(src)
    local identifier = getPlayerIdentifier(xPlayer)

    local previousBankBalance = 0
    if moneyData then
        for _, data in ipairs(moneyData) do
            if data.name == "bank" then
                previousBankBalance = data.amount
                break
            end
        end
    end

    local currentBankBalance = getPlayerAccounts(xPlayer)
    local amountChange = currentBankBalance - previousBankBalance

    if amountChange ~= 0 then
        local isIncome = currentBankBalance >= previousBankBalance and true or false
        local description = locale("transaction_description")
        logTransaction(identifier, description, account.name, math.abs(amountChange), isIncome)
    end
end)


lib.callback.register("ps-banking:server:getTransactionStats", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)

    local result = MySQL.query.await('SELECT COUNT(*) as totalCount, SUM(amount) as totalAmount FROM ps_banking_transactions WHERE identifier = ?', { identifier })
    local transactionData = MySQL.query.await('SELECT amount, date FROM ps_banking_transactions WHERE identifier = ? ORDER BY date DESC LIMIT 50', { identifier })

    return {
        totalCount = result[1].totalCount,
        totalAmount = result[1].totalAmount,
        transactionData = transactionData,
    }
end)

lib.callback.register("ps-banking:server:createNewAccount", function(source, newAccount)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    MySQL.insert.await('INSERT INTO ps_banking_accounts (balance, holder, cardNumber, users, owner) VALUES (?, ?, ?, ?, ?)', { newAccount.balance, newAccount.holder, newAccount.cardNumber, json.encode(newAccount.users), json.encode(newAccount.owner) })
    return true
end)

lib.callback.register("ps-banking:server:getUser", function(source)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    return {
        name = getName(xPlayer),
        identifier = getPlayerIdentifier(xPlayer),
    }
end)

lib.callback.register("ps-banking:server:getAccounts", function(source)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local playerIdentifier = getPlayerIdentifier(xPlayer)
    local accounts = MySQL.query.await('SELECT * FROM ps_banking_accounts')
    local result = {}
    for _, account in ipairs(accounts) do
        local accountData = {
            id = account.id,
            balance = account.balance,
            holder = account.holder,
            cardNumber = account.cardNumber,
            users = json.decode(account.users),
            owner = json.decode(account.owner),
        }
        if accountData.owner.identifier == playerIdentifier then
            accountData.owner.state = true
            table.insert(result, accountData)
        else
            for _, user in ipairs(accountData.users) do
                if user.identifier == playerIdentifier then
                    accountData.owner.state = false
                    table.insert(result, accountData)
                    break
                end
            end
        end
    end
    return result
end)

lib.callback.register("ps-banking:server:deleteAccount", function(source, accountId)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end

    MySQL.query.await('DELETE FROM ps_banking_accounts WHERE id = ?', { accountId })
    return true
end)

lib.callback.register("ps-banking:server:withdrawFromAccount", function(source, accountId, amount)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local account = MySQL.query.await('SELECT * FROM ps_banking_accounts WHERE id = ?', { accountId })
    if #account > 0 then
        local balance = account[1].balance
        if balance >= amount then
            local affectedRows = MySQL.update.await('UPDATE ps_banking_accounts SET balance = balance - ? WHERE id = ?', { amount, accountId })
            if affectedRows > 0 then
                if framework == "ESX" then
                    xPlayer.addAccountMoney("bank", amount)
                elseif framework == "QBCore" then
                    xPlayer.Functions.AddMoney("bank", amount)
                end
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:depositToAccount", function(source, accountId, amount)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    if getPlayerAccounts(xPlayer) >= amount then
        local affectedRows = MySQL.update.await('UPDATE ps_banking_accounts SET balance = balance + ? WHERE id = ?', { amount, accountId })
        if affectedRows > 0 then
            if framework == "ESX" then
                xPlayer.removeAccountMoney("bank", amount)
            elseif framework == "QBCore" then
                xPlayer.Functions.RemoveMoney("bank", amount)
            end
            return true
        else
            return false
        end
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:addUserToAccount", function(source, accountId, userId)
    local xPlayer = getPlayerFromId(source)
    local targetPlayer = getPlayerFromId(userId)
    local promise = promise.new()
    if source == userId then
        return {
            success = false,
            message = locale("cannot_add_self"),
        }
    end
    if not xPlayer then
        return {
            success = false,
            message = locale("player_not_found"),
        }
    end
    if not targetPlayer then
        return {
            success = false,
            message = locale("target_player_not_found"),
        }
    end
    local accounts = MySQL.query.await('SELECT * FROM ps_banking_accounts WHERE id = ?', { accountId })
    if #accounts > 0 then
        local account = accounts[1]
        local users = json.decode(account.users)
        for _, user in ipairs(users) do
            if user.identifier == userId then
                return {
                    success = false,
                    message = locale("user_already_in_account"),
                }
            end
        end
        table.insert(users, {
            name = getName(targetPlayer),
            identifier = getPlayerIdentifier(targetPlayer),
        })
        local affectedRows = MySQL.update.await('UPDATE ps_banking_accounts SET users = ? WHERE id = ?', { json.encode(users), accountId })
        return {
            success = affectedRows > 0,
            userName = getName(targetPlayer),
        }
    else
        return {
            success = false,
            message = locale("account_not_found"),
        }
    end
end)

lib.callback.register("ps-banking:server:removeUserFromAccount", function(source, accountId, userId)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local accounts = MySQL.query.await('SELECT * FROM ps_banking_accounts WHERE id = ?', { accountId })
    if #accounts > 0 then
        local account = accounts[1]
        local users = json.decode(account.users)
        local updatedUsers = {}
        for _, user in ipairs(users) do
            if user.identifier ~= userId then
                table.insert(updatedUsers, user)
            end
        end
        local affectedRows = MySQL.update.await('UPDATE ps_banking_accounts SET users = ? WHERE id = ?', { json.encode(updatedUsers), accountId })
        return affectedRows > 0
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:renameAccount", function(source, id, newName)
    local xPlayer = getPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local affectedRows = MySQL.update.await('UPDATE ps_banking_accounts SET holder = ? WHERE id = ?', { newName, id })
    return affectedRows > 0
end)

lib.callback.register("ps-banking:server:ATMwithdraw", function(source, amount)
    local xPlayer = getPlayerFromId(source)
    local bankBalance = getPlayerAccounts(xPlayer)

    if bankBalance >= amount then
        if framework == "ESX" then
            xPlayer.removeAccountMoney("bank", amount)
            xPlayer.addMoney(amount)
        elseif framework == "QBCore" then
            xPlayer.Functions.RemoveMoney("bank", amount)
            xPlayer.Functions.AddMoney("cash", amount)
        end
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:ATMdeposit", function(source, amount)
    local xPlayer = getPlayerFromId(source)
    local cashBalance = nil
    if framework == "ESX" then
        cashBalance = xPlayer.getMoney()
    elseif framework == "QBCore" then
        cashBalance = xPlayer.PlayerData.money["cash"]
    end

    if cashBalance >= amount then
        if framework == "ESX" then
            xPlayer.removeMoney(amount)
            xPlayer.addAccountMoney("bank", amount)
        elseif framework == "QBCore" then
            xPlayer.Functions.RemoveMoney("cash", amount)
            xPlayer.Functions.AddMoney("bank", amount)
        end
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:getBills", function(source)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    local result = MySQL.query.await('SELECT * FROM ps_banking_bills WHERE identifier = ?', { identifier })
    return result
end)

lib.callback.register("ps-banking:server:payBill", function(source, billId)
    local xPlayer = getPlayerFromId(source)
    local identifier = getPlayerIdentifier(xPlayer)
    local result = MySQL.query.await('SELECT * FROM ps_banking_bills WHERE id = ? AND identifier = ? AND isPaid = 0', { billId, identifier })
    if #result == 0 then
        return false
    end
    local bill = result[1]
    local amount = bill.amount
    if tonumber(getPlayerAccounts(xPlayer)) >= tonumber(amount) then
        if framework == "ESX" then
            xPlayer.removeAccountMoney("bank", tonumber(amount))
        elseif framework == "QBCore" then
            xPlayer.Functions.RemoveMoney("bank", tonumber(amount))
        end
        MySQL.query.await('DELETE FROM ps_banking_bills WHERE id = ?', { billId })
        return true
    else
        return false
    end
end)

function createBill(data)
    local identifier = data.identifier
    local description = data.description
    local type = data.type
    local amount = data.amount

    MySQL.insert.await('INSERT INTO ps_banking_bills (identifier, description, type, amount, date, isPaid) VALUES (?, ?, ?, ?, NOW(), ?)', { identifier, description, type, amount, false })
end
exports("createBill", createBill)

--[[ EXAMPLE
    exports["ps-banking"]:createBill({
        identifier = "char1:df6c12c50e2712c57b1386e7103d5a372fb960a0",
        description = "Utility Bill",
        type = "Expense",
        amount = 150.00,
    })
]]
