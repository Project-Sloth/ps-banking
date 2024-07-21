if GetResourceState("es_extended") ~= "started" then
    return
end

RegisterNUICallback("ps-banking:client:getTransactionStats", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getTransactionStats", false)
    cb(success)
end)

RegisterNetEvent("esx:setAccountMoney", function(account)
    local moneyData = {}
    for k, v in pairs(ESX.GetPlayerData().accounts) do
        table.insert(moneyData, {
            amount = v.money,
            name = v.name == "money" and "cash" or v.name,
        })
    end
    Wait(50)
    TriggerServerEvent("ps-banking:server:logClient", account, moneyData)
end)
