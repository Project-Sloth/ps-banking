-- CreateSQLTable
-- @param tableName The name of the table to create.
-- @param colums A table containing the columns to create in the table.
-- The table should have the following structure:
-- @code
-- {
--     {
--         name = "column1",
--         type = "INT",
--         long = 11,
--         attribs = "NOT NULL",
--         default = 0
--     },
--     {
--         name = "column2",
--         type = "VARCHAR",
--         long = 255,
--         attribs = "NOT NULL",
--         default = "default_value"
--     },
-- }
-- @endcode
function CreateSQLTable(tableName, columns)
    CreateThreadNow(function()
        local consulta = "CREATE TABLE IF NOT EXISTS `" .. tableName .. "` ("
        for i, columna in ipairs(columns) do
            consulta = consulta .. "`" .. columna.name .. "` " .. columna.type
            if columna.long then
                consulta = consulta .. "(" .. columna.long .. ")"
            end
            if columna.attribs then
                consulta = consulta .. " " .. columna.attribs
            end
            if columna.default then
                if type(columna.default) == "string" then
                    consulta = consulta .. " DEFAULT('" .. columna.default .. "')"
                else
                    consulta = consulta .. " DEFAULT(" .. columna.default .. ")"
                end
            end
            if i < #columns then
                consulta = consulta .. ", "
            end
        end
        consulta = consulta .. ");"
        local resultado = MySQL.rawExecute.await(consulta)
        if resultado.warningStatus == 1 then
            print("Table already Created: " .. tableName)
        else
            print("Table created: " .. tableName)
        end
    end)
end

local ps_banking_transactions = {
    { name = "id",          type = "INT",     long = 0,            attribs = "PRIMARY KEY AUTO_INCREMENT" },
    { name = "identifier",  type = "VARCHAR", long = 50,           attribs = "NOT NULL" },
    { name = "description", type = "VARCHAR", long = 255,          attribs = "NOT NULL" },
    { name = "type",        type = "VARCHAR", long = 50,           attribs = "NOT NULL" },
    { name = "amount",      type = "DECIMAL", long = "10,2",       attribs = "NOT NULL" },
    { name = "date",        type = "DATE",    attribs = "NOT NULL" },
    { name = "isIncome",    type = "BOOLEAN", attribs = "NOT NULL" },
}
local ps_banking_bills = {
    { name = "id",          type = "INT",     long = 0,            attribs = "PRIMARY KEY AUTO_INCREMENT" },
    { name = "identifier",  type = "VARCHAR", long = 50,           attribs = "NOT NULL" },
    { name = "description", type = "VARCHAR", long = 255,          attribs = "NOT NULL" },
    { name = "type",        type = "VARCHAR", long = 50,           attribs = "NOT NULL" },
    { name = "amount",      type = "DECIMAL", long = "10,2",       attribs = "NOT NULL" },
    { name = "date",        type = "DATE",    attribs = "NOT NULL" },
    { name = "isPaid",      type = "BOOLEAN", attribs = "NOT NULL" },
}
local ps_banking_accounts = {
    { name = "id",         type = "INT",     long = 0,            attribs = "PRIMARY KEY AUTO_INCREMENT" },
    { name = "balance",    type = "BIGINT",  attribs = "NOT NULL" },
    { name = "holder",     type = "VARCHAR", long = 255,          attribs = "NOT NULL" },
    { name = "cardNumber", type = "VARCHAR", long = 255,          attribs = "NOT NULL" },
    { name = "users",      type = "JSON",    attribs = "NOT NULL" },
    { name = "owner",      type = "JSON",    attribs = "NOT NULL" },
}

CreateSQLTable("ps_banking_transactions", ps_banking_transactions)
CreateSQLTable("ps_banking_bills", ps_banking_bills)
CreateSQLTable("ps_banking_accounts", ps_banking_accounts)