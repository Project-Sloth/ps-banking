if GetResourceState("qb-core") ~= "started" then
    return
end

function logTransaction(identifier, description, accountName, amount, isIncome)
    MySQL.Sync.execute(
        "INSERT INTO ps_banking_transactions (identifier, description, type, amount, date, isIncome) VALUES (@identifier, @description, @type, @amount, NOW(), @isIncome)",
        {
            ["@identifier"] = identifier,
            ["@description"] = description,
            ["@type"] = accountName,
            ["@amount"] = amount,
            ["@isIncome"] = isIncome,
        })
end

RegisterNetEvent("ps-banking:server:logClient", function(account, moneyData)
    if account.name ~= "bank" then
        return
    end
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local identifier = xPlayer.PlayerData.citizenid

    local previousBankBalance = 0
    if moneyData then
        for _, data in ipairs(moneyData) do
            if data.name == "bank" then
                previousBankBalance = data.amount
                break
            end
        end
    end
    local currentBankBalance = xPlayer.PlayerData.money["bank"]
    local amountChange = currentBankBalance - previousBankBalance
    local isIncome = currentBankBalance >= previousBankBalance and true or false
    local description = locale("transaction")
    logTransaction(identifier, description, account.name, math.abs(amountChange), isIncome)
end)

lib.callback.register("ps-banking:server:getTransactionStats", function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local identifier = xPlayer.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll(
        "SELECT COUNT(*) as totalCount, SUM(amount) as totalAmount FROM ps_banking_transactions WHERE identifier = @identifier",
        {
            ["@identifier"] = identifier,
        })
    local transactionData = MySQL.Sync.fetchAll(
        "SELECT amount, date FROM ps_banking_transactions WHERE identifier = @identifier ORDER BY date DESC LIMIT 50", {
            ["@identifier"] = identifier,
        })
    return {
        totalCount = result[1].totalCount,
        totalAmount = result[1].totalAmount,
        transactionData = transactionData,
    }
end)
