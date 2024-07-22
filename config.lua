lib.locale()
Config = {}
Config.LBPhone = false -- Does your server use lb-phone?
Config.TargetSystem = "ox_target" -- Change to your target script like ox_target, qb-target, Or use devyn's interact.

Config.Currency = {
    lang = "en", -- da-DK
    currency = "USD", -- DKK
}

Config.BankLocations = {
    Coords = {
        vector3(149.05, -1041.3, 29.37),
        vector3(313.32, -280.03, 54.17),
        vector3(-351.94, -50.72, 49.04),
        vector3(-1212.68, -331.83, 37.78),
        vector3(-2961.67, 482.31, 15.7),
        vector3(1175.64, 2707.71, 38.09),
        vector3(247.65, 223.87, 106.29),
        vector3(-111.98, 6470.56, 31.63),
    },
    Blips = {
        name = "Bank",
        sprite = 108,
        color = 2,
        scale = 0.55,
    },
}

-- ATM stuff
Config.PresetATM_Amounts = { -- The preset amounts
    Amounts = {
        2000,
        5000,
        10000,
    },
    Grid = 3, -- How many there should be on each
}

Config.ATM_Animation = { -- Anim when opening ATM
    dict = "anim@amb@prop_human_atm@interior@male@enter",
    name = "enter",
    flag = 49,
}

Config.ATM_Models = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}
