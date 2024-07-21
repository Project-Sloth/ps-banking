if Config.FrameWork ~= "QB" then
    return
end

RegisterNUICallback("ps-banking:client:getTransactionStats", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getTransactionStats", false)
    cb(success)
end)

RegisterNetEvent("QBCore:Client:OnMoneyChange", function(moneyType, amount)
    local moneyData = {}
    local PlayerData = QBCore.Functions.GetPlayerData()
    for k, v in pairs(PlayerData.money) do
        table.insert(moneyData, {
            amount = v,
            name = k,
        })
    end
    Wait(50)
    TriggerServerEvent("ps-banking:server:logClient", {
        moneyType = moneyType,
        amount = amount,
    }, moneyData)
end)
