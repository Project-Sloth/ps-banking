if Config.FrameWork ~= "QB" then
    return
end

lib.callback.register("ps-banking:server:getHistory", function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local identifier = xPlayer.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_transactions WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    })
    return result
end)

lib.callback.register("ps-banking:server:deleteHistory", function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local identifier = xPlayer.PlayerData.citizenid
    MySQL.Sync.execute("DELETE FROM ps_banking_transactions WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    })
    return true
end)
