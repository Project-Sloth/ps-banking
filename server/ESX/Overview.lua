if Config.FrameWork ~= "ESX" then
    return
end

lib.callback.register("ps-banking:server:payAllBills", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as total FROM ps_banking_bills WHERE identifier = @identifier AND isPaid = 0", {
            ["@identifier"] = identifier,
        })
    local totalAmount = result[1].total or 0
    local bankBalance = xPlayer.getAccount("bank").money
    if tonumber(bankBalance) >= tonumber(totalAmount) then
        xPlayer.removeAccountMoney("bank", tonumber(totalAmount))
        MySQL.Sync.execute("DELETE FROM ps_banking_bills WHERE identifier = @identifier", {
            ["@identifier"] = identifier,
        })
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:getWeeklySummary", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local receivedResult = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as totalReceived FROM ps_banking_transactions WHERE identifier = @identifier AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)",
        {
            ["@identifier"] = identifier,
        })
    local totalReceived = receivedResult[1].totalReceived or 0
    local usedResult = MySQL.Sync.fetchAll(
        "SELECT SUM(amount) as totalUsed FROM ps_banking_transactions WHERE identifier = @identifier AND DATE(date) >= DATE(NOW() - INTERVAL 7 DAY)",
        {
            ["@identifier"] = identifier,
        })
    local totalUsed = usedResult[1].totalUsed or 0
    return {
        totalReceived = totalReceived,
        totalUsed = totalUsed,
    }
end)

lib.callback.register("ps-banking:server:transferMoney", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(data.id)
    local amount = tonumber(data.amount)

    if data.id == source and data.method == "id" then
        return false, "You cannot send yourself money"
    end

    if xPlayer and targetPlayer and amount > 0 then
        local xPlayerBalance = xPlayer.getAccount("bank").money
        if xPlayerBalance >= amount then
            if data.method == "id" then
                xPlayer.removeAccountMoney("bank", amount)
                targetPlayer.addAccountMoney("bank", amount)
                return true, "You have sent " .. amount .. " to " .. targetPlayer.getName()
            elseif data.method == "phone" then
                exports["lb-phone"]:AddTransaction(targetPlayer.identifier, amount,
                    xPlayer.getName() .. " has sent you " .. amount)
                return true, "You have sent " .. amount .. " to " .. targetPlayer.getName()
            end
        else
            return false, "No Money"
        end
    else
        return false, "The user is not in the city"
    end
end)
