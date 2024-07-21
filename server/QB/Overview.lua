if GetResourceState("qb-core") ~= "started" then
    return
end

lib.callback.register("ps-banking:server:payAllBills", function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local identifier = xPlayer.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as total FROM ps_banking_bills WHERE identifier = @identifier AND isPaid = 0", {
            ["@identifier"] = identifier,
        })
    local totalAmount = result[1].total or 0
    local bankBalance = xPlayer.PlayerData.money["bank"]
    if tonumber(bankBalance) >= tonumber(totalAmount) then
        xPlayer.Functions.RemoveMoney("bank", tonumber(totalAmount))
        MySQL.Sync.execute("DELETE FROM ps_banking_bills WHERE identifier = @identifier", {
            ["@identifier"] = identifier,
        })
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:getWeeklySummary", function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local identifier = xPlayer.PlayerData.citizenid
    local receivedResult = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as totalReceived FROM ps_banking_transactions WHERE identifier = @identifier AND isIncome = @isIncome AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)",
        {
            ["@identifier"] = identifier,
            ["@isIncome"] = true,
        })
    local totalReceived = receivedResult[1].totalReceived or 0
    local usedResult = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as totalUsed FROM ps_banking_transactions WHERE identifier = @identifier AND isIncome = @isIncome AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)",
        {
            ["@identifier"] = identifier,
            ["@isIncome"] = false,
        })
    local totalUsed = usedResult[1].totalUsed or 0
    return {
        totalReceived = totalReceived,
        totalUsed = totalUsed,
    }
end)

lib.callback.register("ps-banking:server:transferMoney", function(source, data)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(data.id)
    local amount = tonumber(data.amount)

    if data.id == source and data.method == "id" then
        return false, locale("cannot_send_self_money")
    end

    if xPlayer and targetPlayer and amount > 0 then
        local xPlayerBalance = xPlayer.PlayerData.money["bank"]
        if xPlayerBalance >= amount then
            if data.method == "id" then
                xPlayer.Functions.RemoveMoney("bank", amount)
                targetPlayer.Functions.AddMoney("bank", amount)
                return true, locale("money_sent", amount, targetPlayer.PlayerData.name)
            elseif data.method == "phone" then
                exports["lb-phone"]:AddTransaction(targetPlayer.PlayerData.citizenid, amount,
                    locale("received_money", xPlayer.PlayerData.name, amount))
                return true, locale("money_sent", amount, targetPlayer.PlayerData.name)
            end
        else
            return false, locale("no_money")
        end
    else
        return false, locale("user_not_in_city")
    end
end)
