-- Teleport Utility Functions for Nora Panel
local teleportUtils = {}

-- Teleport to coordinates
function teleportUtils.TeleportToCoords(coords, heading)
    local playerPed = PlayerPedId()
    
    -- Fade out
    DoScreenFadeOut(Config.Teleport.fadeOutTime)
    Citizen.Wait(Config.Teleport.fadeOutTime)
    
    -- Teleport
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    if heading then
        SetEntityHeading(playerPed, heading)
    end
    
    -- Fade in
    Citizen.Wait(Config.Teleport.fadeTime)
    DoScreenFadeIn(Config.Teleport.fadeInTime)
    
    teleportUtils.ShowNotification("success", "Teleported", "Teleported to coordinates")
end

-- Teleport to player
function teleportUtils.TeleportToPlayer(targetId)
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or targetPed == 0 then
        teleportUtils.ShowNotification("error", "Error", "Target player not found")
        return false
    end
    
    local playerPed = PlayerPedId()
    local targetCoords = GetEntityCoords(targetPed)
    local targetHeading = GetEntityHeading(targetPed)
    
    teleportUtils.TeleportToCoords(targetCoords, targetHeading)
    
    return true
end

-- Teleport player to coordinates
function teleportUtils.TeleportPlayerToCoords(targetId, coords, heading)
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or targetPed == 0 then
        teleportUtils.ShowNotification("error", "Error", "Target player not found")
        return false
    end
    
    -- Fade out target player
    TriggerClientEvent('nora:fadeOut', targetId)
    Citizen.Wait(Config.Teleport.fadeOutTime)
    
    -- Teleport target player
    SetEntityCoords(targetPed, coords.x, coords.y, coords.z)
    if heading then
        SetEntityHeading(targetPed, heading)
    end
    
    -- Fade in target player
    Citizen.Wait(Config.Teleport.fadeTime)
    TriggerClientEvent('nora:fadeIn', targetId)
    
    teleportUtils.ShowNotification("success", "Player Teleported", "Player teleported to coordinates")
    
    return true
end

-- Teleport to marker
function teleportUtils.TeleportToMarker()
    local waypoint = GetFirstBlipInfoId(8)
    if waypoint ~= 0 then
        local coords = GetBlipInfoIdCoord(waypoint)
        local groundZ = 0.0
        
        -- Find ground Z
        for i = 0, 1000 do
            local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, i + 0.0, false)
            if found then
                groundZ = z
                break
            end
        end
        
        teleportUtils.TeleportToCoords({x = coords.x, y = coords.y, z = groundZ + 1.0})
    else
        teleportUtils.ShowNotification("error", "Error", "No waypoint set")
    end
end

-- Teleport to waypoint
function teleportUtils.TeleportToWaypoint()
    teleportUtils.TeleportToMarker()
end

-- Get predefined locations
function teleportUtils.GetPredefinedLocations()
    return {
        {
            name = "Los Santos Airport",
            coords = {x = -1037.0, y = -2737.0, z = 20.0},
            heading = 240.0
        },
        {
            name = "Sandy Shores Airfield",
            coords = {x = 1747.0, y = 3273.0, z = 41.0},
            heading = 105.0
        },
        {
            name = "Mount Chiliad",
            coords = {x = 501.0, y = 5604.0, z = 797.0},
            heading = 0.0
        },
        {
            name = "Vinewood Sign",
            coords = {x = 750.0, y = 1195.0, z = 326.0},
            heading = 0.0
        },
        {
            name = "Maze Bank Tower",
            coords = {x = -75.0, y = -818.0, z = 326.0},
            heading = 0.0
        },
        {
            name = "Del Perro Pier",
            coords = {x = -1850.0, y = -1248.0, z = 8.0},
            heading = 0.0
        },
        {
            name = "Vespucci Beach",
            coords = {x = -1100.0, y = -1690.0, z = 4.0},
            heading = 0.0
        },
        {
            name = "Grove Street",
            coords = {x = 85.0, y = -1956.0, z = 20.0},
            heading = 0.0
        },
        {
            name = "Paleto Bay",
            coords = {x = -275.0, y = 6228.0, z = 31.0},
            heading = 0.0
        },
        {
            name = "Sandy Shores",
            coords = {x = 1961.0, y = 3740.0, z = 32.0},
            heading = 0.0
        },
        {
            name = "Grapeseed",
            coords = {x = 1687.0, y = 4815.0, z = 42.0},
            heading = 0.0
        },
        {
            name = "Chumash",
            coords = {x = -3192.0, y = 1100.0, z = 20.0},
            heading = 0.0
        },
        {
            name = "Fort Zancudo",
            coords = {x = -2047.0, y = 3132.0, z = 32.0},
            heading = 0.0
        },
        {
            name = "Prison",
            coords = {x = 1845.0, y = 2585.0, z = 45.0},
            heading = 0.0
        },
        {
            name = "Casino",
            coords = {x = 925.0, y = 46.0, z = 81.0},
            heading = 0.0
        }
    }
end

-- Teleport to predefined location
function teleportUtils.TeleportToLocation(locationName)
    local locations = teleportUtils.GetPredefinedLocations()
    local location = nil
    
    for _, loc in ipairs(locations) do
        if loc.name == locationName then
            location = loc
            break
        end
    end
    
    if not location then
        teleportUtils.ShowNotification("error", "Error", "Location not found")
        return false
    end
    
    teleportUtils.TeleportToCoords(location.coords, location.heading)
    
    return true
end

-- Get player location
function teleportUtils.GetPlayerLocation()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    return {
        coords = {x = coords.x, y = coords.y, z = coords.z},
        heading = heading
    }
end

-- Save location
function teleportUtils.SaveLocation(name, coords, heading)
    local locations = teleportUtils.GetSavedLocations()
    
    table.insert(locations, {
        name = name,
        coords = coords,
        heading = heading,
        savedAt = os.date('%Y-%m-%d %H:%M:%S')
    })
    
    -- Save to local storage
    SetResourceKvp("nora_saved_locations", json.encode(locations))
    
    teleportUtils.ShowNotification("success", "Location Saved", "Location saved: " .. name)
    
    return true
end

-- Get saved locations
function teleportUtils.GetSavedLocations()
    local data = GetResourceKvpString("nora_saved_locations")
    if data then
        return json.decode(data)
    end
    return {}
end

-- Load location
function teleportUtils.LoadLocation(locationName)
    local locations = teleportUtils.GetSavedLocations()
    
    for _, location in ipairs(locations) do
        if location.name == locationName then
            teleportUtils.TeleportToCoords(location.coords, location.heading)
            return true
        end
    end
    
    teleportUtils.ShowNotification("error", "Error", "Location not found")
    return false
end

-- Delete location
function teleportUtils.DeleteLocation(locationName)
    local locations = teleportUtils.GetSavedLocations()
    local newLocations = {}
    
    for _, location in ipairs(locations) do
        if location.name ~= locationName then
            table.insert(newLocations, location)
        end
    end
    
    -- Save updated locations
    SetResourceKvp("nora_saved_locations", json.encode(newLocations))
    
    teleportUtils.ShowNotification("success", "Location Deleted", "Location deleted: " .. locationName)
    
    return true
end

-- Get nearby players
function teleportUtils.GetNearbyPlayers(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local players = {}
    
    local playerList = GetActivePlayers()
    for _, playerId in ipairs(playerList) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                if distance <= radius then
                    table.insert(players, {
                        id = playerId,
                        name = GetPlayerName(playerId),
                        coords = {x = targetCoords.x, y = targetCoords.y, z = targetCoords.z},
                        distance = distance
                    })
                end
            end
        end
    end
    
    return players
end

-- Get coordinates from input
function teleportUtils.GetCoordsFromInput(input)
    local coords = {}
    local parts = {}
    
    -- Split input by comma
    for part in string.gmatch(input, "[^,]+") do
        table.insert(parts, part:match("^%s*(.-)%s*$")) -- Trim whitespace
    end
    
    if #parts >= 3 then
        coords.x = tonumber(parts[1])
        coords.y = tonumber(parts[2])
        coords.z = tonumber(parts[3])
        
        if coords.x and coords.y and coords.z then
            return coords
        end
    end
    
    return nil
end

-- Validate coordinates
function teleportUtils.ValidateCoords(coords)
    if not coords or not coords.x or not coords.y or not coords.z then
        return false
    end
    
    -- Check if coordinates are within reasonable bounds
    local maxDistance = 10000.0
    if math.abs(coords.x) > maxDistance or math.abs(coords.y) > maxDistance or math.abs(coords.z) > maxDistance then
        return false
    end
    
    return true
end

-- Get ground Z
function teleportUtils.GetGroundZ(x, y)
    local groundZ = 0.0
    
    for i = 0, 1000 do
        local found, z = GetGroundZFor_3dCoord(x, y, i + 0.0, false)
        if found then
            groundZ = z
            break
        end
    end
    
    return groundZ
end

-- Show notification
function teleportUtils.ShowNotification(type, title, message)
    if Config.Notifications.enabled then
        SendNUIMessage({
            type = "notification",
            data = {
                type = type,
                title = title,
                message = message,
                duration = Config.Notifications.duration
            }
        })
    end
end

-- Export functions
exports('TeleportToCoords', teleportUtils.TeleportToCoords)
exports('TeleportToPlayer', teleportUtils.TeleportToPlayer)
exports('TeleportPlayerToCoords', teleportUtils.TeleportPlayerToCoords)
exports('TeleportToMarker', teleportUtils.TeleportToMarker)
exports('TeleportToWaypoint', teleportUtils.TeleportToWaypoint)
exports('GetPredefinedLocations', teleportUtils.GetPredefinedLocations)
exports('TeleportToLocation', teleportUtils.TeleportToLocation)
exports('GetPlayerLocation', teleportUtils.GetPlayerLocation)
exports('SaveLocation', teleportUtils.SaveLocation)
exports('GetSavedLocations', teleportUtils.GetSavedLocations)
exports('LoadLocation', teleportUtils.LoadLocation)
exports('DeleteLocation', teleportUtils.DeleteLocation)
exports('GetNearbyPlayers', teleportUtils.GetNearbyPlayers)
exports('GetCoordsFromInput', teleportUtils.GetCoordsFromInput)
exports('ValidateCoords', teleportUtils.ValidateCoords)
exports('GetGroundZ', teleportUtils.GetGroundZ)