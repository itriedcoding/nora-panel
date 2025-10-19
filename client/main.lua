-- Main Client Script for Nora Panel
local noraPanel = {}

-- Panel state
local isPanelOpen = false
local isSpectating = false
local isFrozen = false
local isNoclip = false

-- Initialize the panel
function noraPanel.Initialize()
    print("^2[Nora Panel]^7 Client initialized")
    
    -- Initialize systems
    noraPanel.InitializeSystems()
    
    -- Register keybinds
    noraPanel.RegisterKeybinds()
    
    -- Register events
    noraPanel.RegisterEvents()
    
    print("^2[Nora Panel]^7 Client systems initialized")
end

-- Initialize systems
function noraPanel.InitializeSystems()
    -- Initialize notification system
    if Config.Notifications.enabled then
        exports[GetCurrentResourceName()]:SetPosition(Config.Notifications.position)
        exports[GetCurrentResourceName()]:SetTheme(Config.UI.theme)
        exports[GetCurrentResourceName()]:SetSound(Config.UI.sounds.enabled, Config.UI.sounds.volume)
    end
    
    -- Initialize ESX if available
    if ESX then
        Citizen.Wait(1000)
        ESX = exports['es_extended']:getSharedObject()
    end
    
    print("^2[Nora Panel]^7 Systems initialized")
end

-- Register keybinds
function noraPanel.RegisterKeybinds()
    -- Open panel
    RegisterKeyMapping('nora_panel', 'Open Nora Panel', 'keyboard', Config.Keys.openPanel)
    RegisterCommand('nora_panel', function()
        noraPanel.TogglePanel()
    end, false)
    
    -- Close panel
    RegisterKeyMapping('nora_close', 'Close Nora Panel', 'keyboard', Config.Keys.closePanel)
    RegisterCommand('nora_close', function()
        noraPanel.ClosePanel()
    end, false)
    
    -- Toggle spectate
    RegisterKeyMapping('nora_spectate', 'Toggle Spectate', 'keyboard', Config.Keys.toggleSpectate)
    RegisterCommand('nora_spectate', function()
        noraPanel.ToggleSpectate()
    end, false)
    
    -- Toggle freeze
    RegisterKeyMapping('nora_freeze', 'Toggle Freeze', 'keyboard', Config.Keys.toggleFreeze)
    RegisterCommand('nora_freeze', function()
        noraPanel.ToggleFreeze()
    end, false)
    
    -- Toggle noclip
    RegisterKeyMapping('nora_noclip', 'Toggle Noclip', 'keyboard', Config.Keys.toggleNoclip)
    RegisterCommand('nora_noclip', function()
        noraPanel.ToggleNoclip()
    end, false)
    
    -- Teleport to marker
    RegisterKeyMapping('nora_tp_marker', 'Teleport to Marker', 'keyboard', Config.Keys.teleportToMarker)
    RegisterCommand('nora_tp_marker', function()
        noraPanel.TeleportToMarker()
    end, false)
    
    -- Teleport to waypoint
    RegisterKeyMapping('nora_tp_waypoint', 'Teleport to Waypoint', 'keyboard', Config.Keys.teleportToWaypoint)
    RegisterCommand('nora_tp_waypoint', function()
        noraPanel.TeleportToWaypoint()
    end, false)
    
    print("^2[Nora Panel]^7 Keybinds registered")
end

-- Register events
function noraPanel.RegisterEvents()
    -- Panel events
    RegisterNetEvent('nora:openPanel', noraPanel.OpenPanel)
    RegisterNetEvent('nora:closePanel', noraPanel.ClosePanel)
    RegisterNetEvent('nora:togglePanel', noraPanel.TogglePanel)
    
    -- Player events
    RegisterNetEvent('nora:heal', noraPanel.HealPlayer)
    RegisterNetEvent('nora:revive', noraPanel.RevivePlayer)
    RegisterNetEvent('nora:freeze', noraPanel.FreezePlayer)
    RegisterNetEvent('nora:spectate', noraPanel.SpectatePlayer)
    RegisterNetEvent('nora:stopSpectate', noraPanel.StopSpectate)
    RegisterNetEvent('nora:teleport', noraPanel.TeleportPlayer)
    RegisterNetEvent('nora:teleportToMarker', noraPanel.TeleportToMarker)
    RegisterNetEvent('nora:teleportToWaypoint', noraPanel.TeleportToWaypoint)
    
    -- Vehicle events
    RegisterNetEvent('nora:spawnVehicle', noraPanel.SpawnVehicle)
    RegisterNetEvent('nora:deleteVehicle', noraPanel.DeleteVehicle)
    RegisterNetEvent('nora:repairVehicle', noraPanel.RepairVehicle)
    RegisterNetEvent('nora:modifyVehicle', noraPanel.ModifyVehicle)
    RegisterNetEvent('nora:teleportToVehicle', noraPanel.TeleportToVehicle)
    RegisterNetEvent('nora:bringVehicle', noraPanel.BringVehicle)
    RegisterNetEvent('nora:lockVehicle', noraPanel.LockVehicle)
    RegisterNetEvent('nora:toggleEngine', noraPanel.ToggleEngine)
    RegisterNetEvent('nora:toggleLights', noraPanel.ToggleLights)
    RegisterNetEvent('nora:toggleSiren', noraPanel.ToggleSiren)
    
    -- Weapon events
    RegisterNetEvent('nora:giveWeapon', noraPanel.GiveWeapon)
    RegisterNetEvent('nora:removeWeapon', noraPanel.RemoveWeapon)
    RegisterNetEvent('nora:removeAllWeapons', noraPanel.RemoveAllWeapons)
    RegisterNetEvent('nora:giveAmmo', noraPanel.GiveAmmo)
    RegisterNetEvent('nora:setWeaponAmmo', noraPanel.SetWeaponAmmo)
    RegisterNetEvent('nora:giveWeaponComponent', noraPanel.GiveWeaponComponent)
    RegisterNetEvent('nora:removeWeaponComponent', noraPanel.RemoveWeaponComponent)
    
    -- Weather events
    RegisterNetEvent('nora:setWeather', noraPanel.SetWeather)
    RegisterNetEvent('nora:freezeWeather', noraPanel.FreezeWeather)
    RegisterNetEvent('nora:setTime', noraPanel.SetTime)
    RegisterNetEvent('nora:freezeTime', noraPanel.FreezeTime)
    RegisterNetEvent('nora:setWind', noraPanel.SetWind)
    RegisterNetEvent('nora:setBlackout', noraPanel.SetBlackout)
    RegisterNetEvent('nora:resetWeather', noraPanel.ResetWeather)
    
    -- Economy events
    RegisterNetEvent('nora:giveMoney', noraPanel.GiveMoney)
    RegisterNetEvent('nora:removeMoney', noraPanel.RemoveMoney)
    RegisterNetEvent('nora:setMoney', noraPanel.SetMoney)
    RegisterNetEvent('nora:transferMoney', noraPanel.TransferMoney)
    
    -- Announcement events
    RegisterNetEvent('nora:announcement', noraPanel.ShowAnnouncement)
    
    -- Notification events
    RegisterNetEvent('nora:notification', noraPanel.ShowNotification)
    
    -- Fade events
    RegisterNetEvent('nora:fadeOut', noraPanel.FadeOut)
    RegisterNetEvent('nora:fadeIn', noraPanel.FadeIn)
    
    print("^2[Nora Panel]^7 Events registered")
end

-- Toggle panel
function noraPanel.TogglePanel()
    if isPanelOpen then
        noraPanel.ClosePanel()
    else
        noraPanel.OpenPanel()
    end
end

-- Open panel
function noraPanel.OpenPanel()
    if not exports[GetCurrentResourceName()]:IsAdmin() then
        exports[GetCurrentResourceName()]:ShowNotification("error", "Access Denied", "You don't have permission to use this panel")
        return
    end
    
    isPanelOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = "openPanel"
    })
    
    -- Play sound
    if Config.UI.sounds.enabled then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    end
end

-- Close panel
function noraPanel.ClosePanel()
    isPanelOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = "closePanel"
    })
    
    -- Play sound
    if Config.UI.sounds.enabled then
        PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    end
end

-- Toggle spectate
function noraPanel.ToggleSpectate()
    if isSpectating then
        noraPanel.StopSpectate()
    else
        noraPanel.StartSpectate()
    end
end

-- Start spectate
function noraPanel.StartSpectate()
    if not exports[GetCurrentResourceName()]:IsAdmin() then
        return
    end
    
    isSpectating = true
    exports[GetCurrentResourceName()]:StartSpectating()
    
    exports[GetCurrentResourceName()]:ShowNotification("info", "Spectating", "You are now spectating")
end

-- Stop spectate
function noraPanel.StopSpectate()
    if not isSpectating then
        return
    end
    
    isSpectating = false
    exports[GetCurrentResourceName()]:StopSpectating()
    
    exports[GetCurrentResourceName()]:ShowNotification("info", "Spectating Stopped", "You are no longer spectating")
end

-- Toggle freeze
function noraPanel.ToggleFreeze()
    if not exports[GetCurrentResourceName()]:IsAdmin() then
        return
    end
    
    isFrozen = not isFrozen
    exports[GetCurrentResourceName()]:FreezePlayer(isFrozen)
end

-- Toggle noclip
function noraPanel.ToggleNoclip()
    if not exports[GetCurrentResourceName()]:IsAdmin() then
        return
    end
    
    isNoclip = not isNoclip
    noraPanel.SetNoclip(isNoclip)
end

-- Set noclip
function noraPanel.SetNoclip(enabled)
    local playerPed = PlayerPedId()
    
    if enabled then
        SetEntityVisible(playerPed, false, false)
        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        
        -- Start noclip thread
        Citizen.CreateThread(function()
            while isNoclip do
                Citizen.Wait(0)
                
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local heading = GetEntityHeading(playerPed)
                
                -- Movement controls
                local speed = Config.Noclip.speed
                if IsControlPressed(0, 21) then -- Shift
                    speed = speed * Config.Noclip.speedMultiplier
                end
                if IsControlPressed(0, 19) then -- Alt
                    speed = speed / Config.Noclip.speedMultiplier
                end
                
                -- Forward/backward
                if IsControlPressed(0, 32) then -- W
                    local forward = GetEntityForwardVector(playerPed)
                    SetEntityCoords(playerPed, coords.x + forward.x * speed, coords.y + forward.y * speed, coords.z + forward.z * speed)
                end
                if IsControlPressed(0, 33) then -- S
                    local forward = GetEntityForwardVector(playerPed)
                    SetEntityCoords(playerPed, coords.x - forward.x * speed, coords.y - forward.y * speed, coords.z - forward.z * speed)
                end
                
                -- Left/right
                if IsControlPressed(0, 34) then -- A
                    local right = GetEntityRightVector(playerPed)
                    SetEntityCoords(playerPed, coords.x - right.x * speed, coords.y - right.y * speed, coords.z - right.z * speed)
                end
                if IsControlPressed(0, 35) then -- D
                    local right = GetEntityRightVector(playerPed)
                    SetEntityCoords(playerPed, coords.x + right.x * speed, coords.y + right.y * speed, coords.z + right.z * speed)
                end
                
                -- Up/down
                if IsControlPressed(0, 44) then -- Q
                    SetEntityCoords(playerPed, coords.x, coords.y, coords.z + speed)
                end
                if IsControlPressed(0, 38) then -- E
                    SetEntityCoords(playerPed, coords.x, coords.y, coords.z - speed)
                end
                
                -- Mouse look
                local mouseX = GetControlNormal(0, 1)
                local mouseY = GetControlNormal(0, 2)
                
                heading = heading + mouseX * 2.0
                SetEntityHeading(playerPed, heading)
            end
        end)
        
        exports[GetCurrentResourceName()]:ShowNotification("info", "Noclip Enabled", "Noclip enabled")
    else
        SetEntityVisible(playerPed, true, false)
        SetEntityCollision(playerPed, true, true)
        FreezeEntityPosition(playerPed, false)
        
        exports[GetCurrentResourceName()]:ShowNotification("info", "Noclip Disabled", "Noclip disabled")
    end
end

-- Teleport to marker
function noraPanel.TeleportToMarker()
    if not exports[GetCurrentResourceName()]:IsAdmin() then
        return
    end
    
    exports[GetCurrentResourceName()]:TeleportToMarker()
end

-- Teleport to waypoint
function noraPanel.TeleportToWaypoint()
    noraPanel.TeleportToMarker()
end

-- Player event handlers
function noraPanel.HealPlayer()
    exports[GetCurrentResourceName()]:HealPlayer()
end

function noraPanel.RevivePlayer()
    exports[GetCurrentResourceName()]:RevivePlayer()
end

function noraPanel.FreezePlayer(freeze)
    exports[GetCurrentResourceName()]:FreezePlayer(freeze)
end

function noraPanel.SpectatePlayer(targetId)
    exports[GetCurrentResourceName()]:SpectatePlayer(targetId)
end

function noraPanel.StopSpectate()
    exports[GetCurrentResourceName()]:StopSpectating()
end

function noraPanel.TeleportPlayer(coords, heading)
    exports[GetCurrentResourceName()]:TeleportPlayer(coords, heading)
end

function noraPanel.TeleportToMarker()
    exports[GetCurrentResourceName()]:TeleportToMarker()
end

function noraPanel.TeleportToWaypoint()
    noraPanel.TeleportToMarker()
end

-- Vehicle event handlers
function noraPanel.SpawnVehicle(model, coords, heading)
    exports[GetCurrentResourceName()]:SpawnVehicle(model, coords, heading)
end

function noraPanel.DeleteVehicle(vehicleId)
    exports[GetCurrentResourceName()]:DeleteVehicle(vehicleId)
end

function noraPanel.RepairVehicle(vehicleId)
    exports[GetCurrentResourceName()]:RepairVehicle(vehicleId)
end

function noraPanel.ModifyVehicle(vehicleId, modifications)
    exports[GetCurrentResourceName()]:ModifyVehicle(vehicleId, modifications)
end

function noraPanel.TeleportToVehicle(vehicleId)
    exports[GetCurrentResourceName()]:TeleportToVehicle(vehicleId)
end

function noraPanel.BringVehicle(vehicleId)
    exports[GetCurrentResourceName()]:BringVehicle(vehicleId)
end

function noraPanel.LockVehicle(vehicleId, lock)
    exports[GetCurrentResourceName()]:LockVehicle(vehicleId, lock)
end

function noraPanel.ToggleEngine(vehicleId, start)
    exports[GetCurrentResourceName()]:ToggleEngine(vehicleId, start)
end

function noraPanel.ToggleLights(vehicleId, on)
    exports[GetCurrentResourceName()]:ToggleLights(vehicleId, on)
end

function noraPanel.ToggleSiren(vehicleId, on)
    exports[GetCurrentResourceName()]:ToggleSiren(vehicleId, on)
end

-- Weapon event handlers
function noraPanel.GiveWeapon(weaponHash, ammo)
    exports[GetCurrentResourceName()]:GiveWeapon(weaponHash, ammo)
end

function noraPanel.RemoveWeapon(weaponHash)
    exports[GetCurrentResourceName()]:RemoveWeapon(weaponHash)
end

function noraPanel.RemoveAllWeapons()
    exports[GetCurrentResourceName()]:RemoveAllWeapons()
end

function noraPanel.GiveAmmo(weaponHash, ammo)
    exports[GetCurrentResourceName()]:GiveAmmo(weaponHash, ammo)
end

function noraPanel.SetWeaponAmmo(weaponHash, ammo)
    exports[GetCurrentResourceName()]:SetWeaponAmmo(weaponHash, ammo)
end

function noraPanel.GiveWeaponComponent(weaponHash, componentHash)
    exports[GetCurrentResourceName()]:GiveWeaponComponent(weaponHash, componentHash)
end

function noraPanel.RemoveWeaponComponent(weaponHash, componentHash)
    exports[GetCurrentResourceName()]:RemoveWeaponComponent(weaponHash, componentHash)
end

-- Weather event handlers
function noraPanel.SetWeather(weatherType, transition)
    exports[GetCurrentResourceName()]:SetWeather(weatherType, transition)
end

function noraPanel.FreezeWeather(freeze)
    exports[GetCurrentResourceName()]:FreezeWeather(freeze)
end

function noraPanel.SetTime(hour, minute, second)
    exports[GetCurrentResourceName()]:SetTime(hour, minute, second)
end

function noraPanel.FreezeTime(freeze)
    exports[GetCurrentResourceName()]:FreezeTime(freeze)
end

function noraPanel.SetWind(windSpeed, windDirection)
    exports[GetCurrentResourceName()]:SetWind(windSpeed, windDirection)
end

function noraPanel.SetBlackout(blackout)
    exports[GetCurrentResourceName()]:SetBlackout(blackout)
end

function noraPanel.ResetWeather()
    exports[GetCurrentResourceName()]:ResetWeather()
end

-- Economy event handlers
function noraPanel.GiveMoney(amount, account)
    exports[GetCurrentResourceName()]:GiveMoney(amount, account)
end

function noraPanel.RemoveMoney(amount, account)
    exports[GetCurrentResourceName()]:RemoveMoney(amount, account)
end

function noraPanel.SetMoney(amount, account)
    exports[GetCurrentResourceName()]:SetMoney(amount, account)
end

function noraPanel.TransferMoney(fromAccount, toAccount, amount)
    exports[GetCurrentResourceName()]:TransferMoney(fromAccount, toAccount, amount)
end

-- Announcement event handlers
function noraPanel.ShowAnnouncement(data)
    exports[GetCurrentResourceName()]:ShowAnnouncement(data.title, data.message, data.type)
end

-- Notification event handlers
function noraPanel.ShowNotification(data)
    exports[GetCurrentResourceName()]:ShowNotification(data.type, data.title, data.message, data.duration)
end

-- Fade event handlers
function noraPanel.FadeOut()
    DoScreenFadeOut(Config.Teleport.fadeOutTime)
end

function noraPanel.FadeIn()
    DoScreenFadeIn(Config.Teleport.fadeInTime)
end

-- NUI callbacks
RegisterNUICallback('closePanel', function(data, cb)
    noraPanel.ClosePanel()
    cb('ok')
end)

RegisterNUICallback('getPlayerData', function(data, cb)
    local playerData = exports[GetCurrentResourceName()]:GetPlayerData()
    cb(playerData)
end)

RegisterNUICallback('getAllPlayers', function(data, cb)
    local players = exports[GetCurrentResourceName()]:GetAllPlayersData()
    cb(players)
end)

RegisterNUICallback('getVehicleList', function(data, cb)
    local vehicles = exports[GetCurrentResourceName()]:GetVehicleList()
    cb(vehicles)
end)

RegisterNUICallback('getWeaponList', function(data, cb)
    local weapons = exports[GetCurrentResourceName()]:GetWeaponList()
    cb(weapons)
end)

RegisterNUICallback('getWeatherTypes', function(data, cb)
    local weatherTypes = exports[GetCurrentResourceName()]:GetWeatherTypes()
    cb(weatherTypes)
end)

RegisterNUICallback('getWeatherPresets', function(data, cb)
    local presets = exports[GetCurrentResourceName()]:GetWeatherPresets()
    cb(presets)
end)

RegisterNUICallback('getPredefinedLocations', function(data, cb)
    local locations = exports[GetCurrentResourceName()]:GetPredefinedLocations()
    cb(locations)
end)

RegisterNUICallback('getSavedLocations', function(data, cb)
    local locations = exports[GetCurrentResourceName()]:GetSavedLocations()
    cb(locations)
end)

RegisterNUICallback('saveLocation', function(data, cb)
    local success = exports[GetCurrentResourceName()]:SaveLocation(data.name, data.coords, data.heading)
    cb(success)
end)

RegisterNUICallback('loadLocation', function(data, cb)
    local success = exports[GetCurrentResourceName()]:LoadLocation(data.name)
    cb(success)
end)

RegisterNUICallback('deleteLocation', function(data, cb)
    local success = exports[GetCurrentResourceName()]:DeleteLocation(data.name)
    cb(success)
end)

-- Initialize the panel
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait 1 second after resource start
    noraPanel.Initialize()
end)

-- Export functions
exports('TogglePanel', noraPanel.TogglePanel)
exports('OpenPanel', noraPanel.OpenPanel)
exports('ClosePanel', noraPanel.ClosePanel)
exports('ToggleSpectate', noraPanel.ToggleSpectate)
exports('ToggleFreeze', noraPanel.ToggleFreeze)
exports('ToggleNoclip', noraPanel.ToggleNoclip)
exports('TeleportToMarker', noraPanel.TeleportToMarker)
exports('TeleportToWaypoint', noraPanel.TeleportToWaypoint)