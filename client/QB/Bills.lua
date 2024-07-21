if GetResourceState("qb-core") ~= "started" then
    return
end

RegisterNUICallback("ps-banking:client:getBills", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getBills", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:payBill", function(data, cb)
    local success = lib.callback.await("ps-banking:server:payBill", false, data.id)
    cb(success)
end)
