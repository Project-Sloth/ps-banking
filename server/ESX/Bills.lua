if Config.FrameWork ~= "ESX" then
    return
end

lib.callback.register("ps-banking:server:getBills", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.Sync.fetchAll("SELECT * FROM ps_banking_bills WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    })
    return result
end)

lib.callback.register("ps-banking:server:payBill", function(source, billId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local result = MySQL.Sync.fetchAll(
        "SELECT * FROM ps_banking_bills WHERE id = @id AND identifier = @identifier AND isPaid = 0", {
            ["@id"] = billId,
            ["@identifier"] = identifier,
        })
    if #result == 0 then
        return false
    end
    local bill = result[1]
    local amount = bill.amount
    if tonumber(xPlayer.getAccount("bank").money) >= tonumber(amount) then
        xPlayer.removeAccountMoney("bank", tonumber(amount))
        MySQL.Sync.execute("DELETE FROM ps_banking_bills WHERE id = @id", {
            ["@id"] = billId,
        })
        return true
    else
        return false
    end
end)

function createBill(data)
    local identifier = data.identifier
    local description = data.description
    local type = data.type
    local amount = data.amount
    MySQL.Sync.execute(
        "INSERT INTO ps_banking_bills (identifier, description, type, amount, date, isPaid) VALUES (@identifier, @description, @type, @amount, @date, @isPaid)",
        {
            ["@identifier"] = identifier,
            ["@description"] = description,
            ["@type"] = type,
            ["@amount"] = amount,
            ["@date"] = os.date("%Y-%m-%d"),
            ["@isPaid"] = false,
        })
end
exports("createBill", createBill)

--[[ EXAMPLE
    exports["ps-banking"]:createBill({
        identifier = "char1:df6c12c50e2712c57b1386e7103d5a372fb960a0",
        description = "Utility Bill",
        type = "Expense",
        amount = 150.00,
    })
]]
