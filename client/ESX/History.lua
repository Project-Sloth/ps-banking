if Config.FrameWork ~= "ESX" then
    return
end

RegisterNUICallback("ps-banking:client:getHistory", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getHistory", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:deleteHistory", function(data, cb)
    local success = lib.callback.await("ps-banking:server:deleteHistory", false)
    cb(success)
end)

