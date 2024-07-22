fx_version "cerulean"
game "gta5"
author "Project Sloth"
lua54 "yes"
ui_page "html/index.html"
version "1.0.0"
-- ui_page "http://localhost:5173"

client_scripts {
    "client/**/*",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
}

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
}

files {
    "html/**/*",
    "locales/**/*",
}

