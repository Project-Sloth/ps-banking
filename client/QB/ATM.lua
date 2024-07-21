if Config.FrameWork ~= "QB" then
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
    local PlayerData = QBCore.Functions.GetPlayerData()
    for k, v in pairs(PlayerData.money) do
        table.insert(moneyData, {
            amount = v,
            name = k == "cash" and "cash" or k,
        })
    end
    cb(moneyData)
end)

RegisterNUICallback("ps-banking:client:getAmountPresets", function(_, cb)
    cb(json.encode({
        withdrawAmounts = Config.PresetATM_Amounts.Amounts,
        depositAmounts = Config.PresetATM_Amounts.Amounts,
        grid = Config.PresetATM_Amounts.Grid,
    }))
end)
