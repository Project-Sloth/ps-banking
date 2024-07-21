if GetResourceState("es_extended") ~= "started" then
    return
end

lib.callback.register("ps-banking:server:getHistory", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_transactions WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    })
    return result
end)

lib.callback.register("ps-banking:server:deleteHistory", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    MySQL.Sync.execute("DELETE FROM ps_banking_transactions WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    })
    return true
end)
