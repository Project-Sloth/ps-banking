lib.locale()

RegisterNUICallback("ps-banking:client:getLocales", function(_, cb)
    cb(lib.getLocales())
end)

RegisterNUICallback("ps-banking:client:hideUI", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

Citizen.CreateThread(function()
    for _, location in pairs(Config.BankLocations.Coords) do
        exports["qb-target"]:AddBoxZone("bank", vector3(location), 1.5, 1.6, {
            name = "bank",
            heading = 0.0,
            debugPoly = false,
            minZ = location.z - 1,
            maxZ = location.z + 1,
        }, {
            options = {
                {
                    icon = "fas fa-credit-card",
                    label = locale("openBank"),
                    action = function()
                        SendNUIMessage({
                            action = "openBank",
                        })
                        SetNuiFocus(true, true)
                    end,
                },
            },
            distance = 2.5,
        })
    end

    for i = 1, #Config.BankLocations.Coords do
        local blip = AddBlipForCoord(vector3(Config.BankLocations.Coords[i].x, Config.BankLocations.Coords[i].y,
            Config.BankLocations.Coords[i].z))
        SetBlipSprite(blip, Config.BankLocations.Blips.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.BankLocations.Blips.scale)
        SetBlipColour(blip, Config.BankLocations.Blips.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.BankLocations.Blips.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ATM
function ATM_Animation()
    lib.requestAnimDict(Config.ATM_Animation.dict)
    TaskPlayAnim(PlayerPedId(), Config.ATM_Animation.dict, Config.ATM_Animation.name, 8.0, -8.0, -1,
        Config.ATM_Animation.flag, 0, false, false, false)
    Wait(3000)
    ClearPedTasks(PlayerPedId())
end

exports["qb-target"]:AddTargetModel(Config.ATM_Models, {
    options = {
        {
            icon = "fas fa-solid fa-money-bills",
            label = locale("openATM"),
            action = function()
                ATM_Animation()
                SendNUIMessage({
                    action = "openATM",
                })
                SetNuiFocus(true, true)
            end,
        },
    },
    distance = 2.5,
})
