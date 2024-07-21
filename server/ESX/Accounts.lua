if Config.FrameWork ~= "ESX" then
    return
end

lib.callback.register("ps-banking:server:createNewAccount", function(source, newAccount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local promise = promise.new()
    MySQL.Async.execute(
        "INSERT INTO ps_banking_accounts (balance, holder, cardNumber, users, owner) VALUES (@balance, @holder, @cardNumber, @users, @owner)",
        {
            ["@balance"] = newAccount.balance,
            ["@holder"] = newAccount.holder,
            ["@cardNumber"] = newAccount.cardNumber,
            ["@users"] = json.encode(newAccount.users),
            ["@owner"] = json.encode(newAccount.owner),
        }, function(rowsChanged)
            promise:resolve(rowsChanged > 0)
        end)
    return Citizen.Await(promise)
end)

lib.callback.register("ps-banking:server:getUser", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    return {
        name = xPlayer.getName(),
        identifier = xPlayer.getIdentifier(),
    }
end)

lib.callback.register("ps-banking:server:getAccounts", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local playerIdentifier = xPlayer.getIdentifier()
    local accounts = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_accounts", {})
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
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local promise = promise.new()
    MySQL.Async.execute("DELETE FROM ps_banking_accounts WHERE id = @id", {
        ["@id"] = accountId,
    }, function(rowsChanged)
        promise:resolve(rowsChanged > 0)
    end)
    return Citizen.Await(promise)
end)

lib.callback.register("ps-banking:server:withdrawFromAccount", function(source, accountId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local account = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_accounts WHERE id = @id", {
        ["@id"] = accountId,
    })
    if #account > 0 then
        local balance = account[1].balance
        if balance >= amount then
            local promise = promise.new()
            MySQL.Async.execute("UPDATE ps_banking_accounts SET balance = balance - @amount WHERE id = @id", {
                ["@amount"] = amount,
                ["@id"] = accountId,
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    xPlayer.addAccountMoney("bank", amount)
                    promise:resolve(true)
                else
                    promise:resolve(false)
                end
            end)
            return Citizen.Await(promise)
        else
            return false
        end
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:depositToAccount", function(source, accountId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    if xPlayer.getAccount("bank").money >= amount then
        local promise = promise.new()
        MySQL.Async.execute("UPDATE ps_banking_accounts SET balance = balance + @amount WHERE id = @id", {
            ["@amount"] = amount,
            ["@id"] = accountId,
        }, function(rowsChanged)
            if rowsChanged > 0 then
                xPlayer.removeAccountMoney("bank", amount)
                promise:resolve(true)
            else
                promise:resolve(false)
            end
        end)
        return Citizen.Await(promise)
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:addUserToAccount", function(source, accountId, userId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(userId)
    local promise = promise.new()
    if source == userId then
        promise:resolve({
            success = false,
            message = "You cannot add yourself",
        })
    end
    if not xPlayer then
        promise:resolve({
            success = false,
            message = "Player not found",
        })
        return Citizen.Await(promise)
    end
    if not targetPlayer then
        promise:resolve({
            success = false,
            message = "Target player not found",
        })
        return Citizen.Await(promise)
    end
    local accounts = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_accounts WHERE id = @id", {
        ["@id"] = accountId,
    })
    if #accounts > 0 then
        local account = accounts[1]
        local users = json.decode(account.users)
        for _, user in ipairs(users) do
            if user.identifier == userId then
                promise:resolve({
                    success = false,
                    message = "User already in account",
                })
                return Citizen.Await(promise)
            end
        end
        table.insert(users, {
            name = targetPlayer.getName(),
            identifier = userId,
        })
        MySQL.Async.execute("UPDATE ps_banking_accounts SET users = @users WHERE id = @id", {
            ["@users"] = json.encode(users),
            ["@id"] = accountId,
        }, function(rowsChanged)
            promise:resolve({
                success = rowsChanged > 0,
                userName = targetPlayer.getName(),
            })
        end)
    else
        promise:resolve({
            success = false,
            message = "Account not found",
        })
    end

    return Citizen.Await(promise)
end)

lib.callback.register("ps-banking:server:removeUserFromAccount", function(source, accountId, userId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local promise = promise.new()
    local accounts = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_accounts WHERE id = @id", {
        ["@id"] = accountId,
    })
    if #accounts > 0 then
        local account = accounts[1]
        local users = json.decode(account.users)
        local updatedUsers = {}
        for _, user in ipairs(users) do
            if user.identifier ~= userId then
                table.insert(updatedUsers, user)
            end
        end
        MySQL.Async.execute("UPDATE ps_banking_accounts SET users = @users WHERE id = @id", {
            ["@users"] = json.encode(updatedUsers),
            ["@id"] = accountId,
        }, function(rowsChanged)
            promise:resolve(rowsChanged > 0)
        end)
    else
        promise:resolve(false)
    end
    return Citizen.Await(promise)
end)

lib.callback.register("ps-banking:server:renameAccount", function(source, id, newName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    local promise = promise.new()
    MySQL.Async.execute("UPDATE ps_banking_accounts SET holder = @newName WHERE id = @id", {
        ["@newName"] = newName,
        ["@id"] = id,
    }, function(rowsChanged)
        promise:resolve(rowsChanged > 0)
    end)
    return Citizen.Await(promise)
end)
