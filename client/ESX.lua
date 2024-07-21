if GetResourceState("es_extended") ~= "started" then
    return
end
ESX = exports["es_extended"]:getSharedObject()

RegisterNUICallback("ps-banking:client:getBills", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getBills", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:payBill", function(data, cb)
    local success = lib.callback.await("ps-banking:server:payBill", false, data.id)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:getHistory", function(data, cb)
    local success = lib.callback.await("ps-banking:server:getHistory", false)
    cb(success)
end)

RegisterNUICallback("ps-banking:client:deleteHistory", function(data, cb)
    local success = lib.callback.await("ps-banking:server:deleteHistory", false)
    cb(success)
end)

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

RegisterNUICallback("ps-banking:client:getAmountPresets", function(_, cb)
    cb(json.encode({
        withdrawAmounts = Config.PresetATM_Amounts.Amounts,
        depositAmounts = Config.PresetATM_Amounts.Amounts,
        grid = Config.PresetATM_Amounts.Grid,
    }))
end)

