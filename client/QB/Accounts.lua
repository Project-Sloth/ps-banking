if GetResourceState("qb-core") ~= "started" then
    return
end

RegisterNUICallback("ps-banking:client:createNewAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:createNewAccount", false, data.newAccount)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:getUser", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getUser", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:getAccounts", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getAccounts", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:deleteAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:deleteAccount", false, data.accountId)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:withdrawFromAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:withdrawFromAccount", false, data.accountId, data.amount)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:depositToAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:depositToAccount", false, data.accountId, data.amount)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:addUserToAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:addUserToAccount", false, data.accountId, data.userId)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:removeUserFromAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:removeUserFromAccount", false, data.accountId, data.user)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:renameAccount", function(data, cb)
    local success = lib.callback.await("ps-banking:server:renameAccount", false, data.id, data.newName)
    cb({
        success = success,
    })
end)

RegisterNUICallback("ps-banking:client:copyAccountNumber", function(data, cb)
    lib.setClipboard(data.accountNumber)
    cb(true)
end)

