if GetResourceState("qb-core") ~= "started" then
    return
end
QBCore = exports["qb-core"]:GetCoreObject()

lib.callback.register("ps-banking:server:ATMwithdraw", function(source, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local bankBalance = xPlayer.PlayerData.money["bank"]

    if bankBalance >= amount then
        xPlayer.Functions.RemoveMoney("bank", amount)
        xPlayer.Functions.AddMoney("cash", amount)
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:ATMdeposit", function(source, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local cashBalance = xPlayer.PlayerData.money["cash"]

    if cashBalance >= amount then
        xPlayer.Functions.RemoveMoney("cash", amount)
        xPlayer.Functions.AddMoney("bank", amount)
        return true
    else
        return false
    end
end)
