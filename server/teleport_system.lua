-- Advanced Teleport System for Nora Panel
local teleportSystem = {}

-- Teleport player to coordinates
function teleportSystem.TeleportPlayer(source, targetId, coords, heading)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Teleport player on client side
    TriggerClientEvent('nora:teleport', targetId, coords, heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Player teleported",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Coords: " .. json.encode(coords) .. (heading and " | Heading: " .. heading or ""),
        GetPlayerEndpoint(source)
    )
    
    return true, "Player teleported successfully"
end

-- Teleport player to another player
function teleportSystem.TeleportToPlayer(source, targetId, destinationId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    local destinationIdentifier = GetPlayerIdentifier(destinationId)
    local destinationName = GetPlayerName(destinationId)
    
    -- Get destination player coords
    local destinationPlayer = GetPlayerPed(destinationId)
    if not destinationPlayer then
        return false, "Destination player not found"
    end
    
    local coords = GetEntityCoords(destinationPlayer)
    local heading = GetEntityHeading(destinationPlayer)
    
    -- Teleport player on client side
    TriggerClientEvent('nora:teleport', targetId, {x = coords.x, y = coords.y, z = coords.z}, heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Player teleported to player",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Teleported to: " .. destinationName,
        GetPlayerEndpoint(source)
    )
    
    return true, "Player teleported to " .. destinationName .. " successfully"
end

-- Bring player to admin
function teleportSystem.BringPlayer(source, targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Get admin coords
    local adminPlayer = GetPlayerPed(source)
    local coords = GetEntityCoords(adminPlayer)
    local heading = GetEntityHeading(adminPlayer)
    
    -- Teleport player on client side
    TriggerClientEvent('nora:teleport', targetId, {x = coords.x, y = coords.y, z = coords.z}, heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Player brought to admin",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Brought to admin location",
        GetPlayerEndpoint(source)
    )
    
    return true, "Player brought successfully"
end

-- Go to player
function teleportSystem.GoToPlayer(source, targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Get target player coords
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Target player not found"
    end
    
    local coords = GetEntityCoords(targetPlayer)
    local heading = GetEntityHeading(targetPlayer)
    
    -- Teleport admin on client side
    TriggerClientEvent('nora:teleport', source, {x = coords.x, y = coords.y, z = coords.z}, heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Admin went to player",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Admin teleported to player location",
        GetPlayerEndpoint(source)
    )
    
    return true, "Teleported to " .. targetName .. " successfully"
end

-- Teleport to marker
function teleportSystem.TeleportToMarker(source, targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Teleport to marker on client side
    TriggerClientEvent('nora:teleportToMarker', targetId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Player teleported to marker",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Teleported to map marker",
        GetPlayerEndpoint(source)
    )
    
    return true, "Player teleported to marker successfully"
end

-- Get predefined locations
function teleportSystem.GetPredefinedLocations()
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
function teleportSystem.TeleportToLocation(source, targetId, locationName)
    local locations = teleportSystem.GetPredefinedLocations()
    local location = nil
    
    for _, loc in ipairs(locations) do
        if loc.name == locationName then
            location = loc
            break
        end
    end
    
    if not location then
        return false, "Location not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Teleport player on client side
    TriggerClientEvent('nora:teleport', targetId, location.coords, location.heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Player teleported to location",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Location: " .. locationName,
        GetPlayerEndpoint(source)
    )
    
    return true, "Player teleported to " .. locationName .. " successfully"
end

-- Get player location
function teleportSystem.GetPlayerLocation(targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return nil
    end
    
    local coords = GetEntityCoords(targetPlayer)
    local heading = GetEntityHeading(targetPlayer)
    
    return {
        coords = {x = coords.x, y = coords.y, z = coords.z},
        heading = heading
    }
end

-- Save location
function teleportSystem.SaveLocation(source, name, coords, heading)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Save location to database (you can implement this)
    -- For now, we'll just log it
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "teleport",
        "Location saved",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Location: " .. name .. " | Coords: " .. json.encode(coords),
        GetPlayerEndpoint(source)
    )
    
    return true, "Location saved successfully"
end

-- Export functions
exports('TeleportPlayer', teleportSystem.TeleportPlayer)
exports('TeleportToPlayer', teleportSystem.TeleportToPlayer)
exports('BringPlayer', teleportSystem.BringPlayer)
exports('GoToPlayer', teleportSystem.GoToPlayer)
exports('TeleportToMarker', teleportSystem.TeleportToMarker)
exports('GetPredefinedLocations', teleportSystem.GetPredefinedLocations)
exports('TeleportToLocation', teleportSystem.TeleportToLocation)
exports('GetPlayerLocation', teleportSystem.GetPlayerLocation)
exports('SaveLocation', teleportSystem.SaveLocation)