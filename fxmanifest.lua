fx_version "cerulean"
game "gta5"
author "Project Sloth"
lua54 "yes"
-- ui_page "html/index.html"
ui_page "http://localhost:5173"

client_scripts {
    "client/**/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
}

shared_scripts {
    "@ox_lib/init.lua",
    "Config.lua",
}

files {
    "html/**/*",
    "locales/**/*",
}

