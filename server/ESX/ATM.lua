if GetResourceState("es_extended") ~= "started" then
    return
end
ESX = exports["es_extended"]:getSharedObject()

lib.callback.register("ps-banking:server:ATMwithdraw", function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankBalance = xPlayer.getAccount("bank").money

    if bankBalance >= amount then
        xPlayer.removeAccountMoney("bank", amount)
        xPlayer.addMoney(amount)
        return true
    else
        return false
    end
end)

lib.callback.register("ps-banking:server:ATMdeposit", function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cashBalance = xPlayer.getMoney()

    if cashBalance >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney("bank", amount)
        return true
    else
        return false
    end
end)
