if Config.FrameWork ~= "ESX" then
    return
end

RegisterNUICallback("ps-banking:client:ATMwithdraw", function(data, cb)
    local success = lib.callback.await("ps-banking:server:ATMwithdraw", false, data.amount)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:ATMdeposit", function(data, cb)
    local success = lib.callback.await("ps-banking:server:ATMdeposit", false, data.amount)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:getMoneyTypes", function(data, cb)
    local moneyData = {}
    for k, v in pairs(ESX.GetPlayerData().accounts) do
        table.insert(moneyData, {
            amount = v.money,
            name = v.name == "money" and "cash" or v.name,
        })
    end
    cb(moneyData)
end)

