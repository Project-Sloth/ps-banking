if Config.FrameWork ~= "QB" then
    return
end

QBCore = exports['qb-core']:GetCoreObject()

RegisterNUICallback("ps-banking:client:payAllBills", function(data, cb)
    local success = lib.callback.await("ps-banking:server:payAllBills", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:getWeeklySummary", function(data, cb)
    local summary = lib.callback.await("ps-banking:server:getWeeklySummary", false)
    cb(summary)
end)

RegisterNUICallback("ps-banking:client:transferMoney", function(data, cb)
    local success, message = lib.callback.await("ps-banking:server:transferMoney", false, data)
    cb({
        success = success,
        message = message,
    })
end)
