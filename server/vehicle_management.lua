-- Advanced Vehicle Management System for Nora Panel
local vehicleManagement = {}

-- Spawn vehicle for player
function vehicleManagement.SpawnVehicle(source, targetId, model, coords, heading)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Spawn vehicle on client side
    TriggerClientEvent('nora:spawnVehicle', targetId, model, coords, heading)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Vehicle spawned",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle: " .. model .. " | Coords: " .. json.encode(coords),
        GetPlayerEndpoint(source)
    )
    
    return true, "Vehicle spawned successfully"
end

-- Delete vehicle
function vehicleManagement.DeleteVehicle(source, targetId, vehicleId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Delete vehicle on client side
    TriggerClientEvent('nora:deleteVehicle', targetId, vehicleId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Vehicle deleted",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Vehicle deleted successfully"
end

-- Repair vehicle
function vehicleManagement.RepairVehicle(source, targetId, vehicleId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Repair vehicle on client side
    TriggerClientEvent('nora:repairVehicle', targetId, vehicleId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Vehicle repaired",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Vehicle repaired successfully"
end

-- Modify vehicle
function vehicleManagement.ModifyVehicle(source, targetId, vehicleId, modifications)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Modify vehicle on client side
    TriggerClientEvent('nora:modifyVehicle', targetId, vehicleId, modifications)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Vehicle modified",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId .. " | Modifications: " .. json.encode(modifications),
        GetPlayerEndpoint(source)
    )
    
    return true, "Vehicle modified successfully"
end

-- Get vehicle list
function vehicleManagement.GetVehicleList()
    local vehicles = {}
    
    -- Get all vehicle models
    for i = 0, GetNumVehicleModels() - 1 do
        local model = GetHashKey(GetVehicleModelFromIndex(i))
        local name = GetDisplayNameFromVehicleModel(model)
        local class = GetVehicleClassFromName(model)
        local className = GetVehicleClassDisplayName(class)
        
        table.insert(vehicles, {
            model = model,
            name = name,
            class = class,
            className = className
        })
    end
    
    return vehicles
end

-- Get vehicle classes
function vehicleManagement.GetVehicleClasses()
    local classes = {}
    
    for i = 0, 21 do
        local className = GetVehicleClassDisplayName(i)
        if className and className ~= "NULL" then
            table.insert(classes, {
                id = i,
                name = className
            })
        end
    end
    
    return classes
end

-- Get vehicles by class
function vehicleManagement.GetVehiclesByClass(classId)
    local vehicles = {}
    
    for i = 0, GetNumVehicleModels() - 1 do
        local model = GetHashKey(GetVehicleModelFromIndex(i))
        local class = GetVehicleClassFromName(model)
        
        if class == classId then
            local name = GetDisplayNameFromVehicleModel(model)
            local className = GetVehicleClassDisplayName(class)
            
            table.insert(vehicles, {
                model = model,
                name = name,
                class = class,
                className = className
            })
        end
    end
    
    return vehicles
end

-- Search vehicles
function vehicleManagement.SearchVehicles(query)
    local vehicles = {}
    local queryLower = string.lower(query)
    
    for i = 0, GetNumVehicleModels() - 1 do
        local model = GetHashKey(GetVehicleModelFromIndex(i))
        local name = GetDisplayNameFromVehicleModel(model)
        local class = GetVehicleClassFromName(model)
        local className = GetVehicleClassDisplayName(class)
        
        if string.find(string.lower(name), queryLower) or string.find(string.lower(className), queryLower) then
            table.insert(vehicles, {
                model = model,
                name = name,
                class = class,
                className = className
            })
        end
    end
    
    return vehicles
end

-- Get nearby vehicles
function vehicleManagement.GetNearbyVehicles(source, targetId, radius)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return {}
    end
    
    local coords = GetEntityCoords(targetPlayer)
    local vehicles = {}
    
    -- Get all vehicles in radius
    local vehicleList = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicleList) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)
        
        if distance <= radius then
            local model = GetEntityModel(vehicle)
            local name = GetDisplayNameFromVehicleModel(model)
            local class = GetVehicleClassFromName(model)
            local className = GetVehicleClassDisplayName(class)
            local health = GetEntityHealth(vehicle)
            local maxHealth = GetEntityMaxHealth(vehicle)
            local fuel = GetVehicleFuelLevel(vehicle)
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local bodyHealth = GetVehicleBodyHealth(vehicle)
            local tankHealth = GetVehiclePetrolTankHealth(vehicle)
            
            table.insert(vehicles, {
                id = vehicle,
                model = model,
                name = name,
                class = class,
                className = className,
                coords = {x = vehicleCoords.x, y = vehicleCoords.y, z = vehicleCoords.z},
                distance = distance,
                health = health,
                maxHealth = maxHealth,
                fuel = fuel,
                engineHealth = engineHealth,
                bodyHealth = bodyHealth,
                tankHealth = tankHealth,
                locked = GetVehicleDoorLockStatus(vehicle),
                engine = GetIsVehicleEngineRunning(vehicle),
                lights = GetVehicleLightsState(vehicle),
                siren = IsVehicleSirenOn(vehicle)
            })
        end
    end
    
    return vehicles
end

-- Teleport to vehicle
function vehicleManagement.TeleportToVehicle(source, targetId, vehicleId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Teleport to vehicle on client side
    TriggerClientEvent('nora:teleportToVehicle', targetId, vehicleId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Teleport to vehicle",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Teleported to vehicle successfully"
end

-- Bring vehicle
function vehicleManagement.BringVehicle(source, targetId, vehicleId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Bring vehicle on client side
    TriggerClientEvent('nora:bringVehicle', targetId, vehicleId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        "Bring vehicle",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Vehicle brought successfully"
end

-- Lock vehicle
function vehicleManagement.LockVehicle(source, targetId, vehicleId, lock)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Lock/unlock vehicle on client side
    TriggerClientEvent('nora:lockVehicle', targetId, vehicleId, lock)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        lock and "Vehicle locked" or "Vehicle unlocked",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, (lock and "Vehicle locked" or "Vehicle unlocked") .. " successfully"
end

-- Start/stop engine
function vehicleManagement.ToggleEngine(source, targetId, vehicleId, start)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Toggle engine on client side
    TriggerClientEvent('nora:toggleEngine', targetId, vehicleId, start)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        start and "Vehicle engine started" or "Vehicle engine stopped",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, (start and "Engine started" or "Engine stopped") .. " successfully"
end

-- Toggle lights
function vehicleManagement.ToggleLights(source, targetId, vehicleId, on)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Toggle lights on client side
    TriggerClientEvent('nora:toggleLights', targetId, vehicleId, on)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        on and "Vehicle lights on" or "Vehicle lights off",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, (on and "Lights turned on" or "Lights turned off") .. " successfully"
end

-- Toggle siren
function vehicleManagement.ToggleSiren(source, targetId, vehicleId, on)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Toggle siren on client side
    TriggerClientEvent('nora:toggleSiren', targetId, vehicleId, on)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "vehicle",
        on and "Vehicle siren on" or "Vehicle siren off",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Vehicle ID: " .. vehicleId,
        GetPlayerEndpoint(source)
    )
    
    return true, (on and "Siren turned on" or "Siren turned off") .. " successfully"
end

-- Export functions
exports('SpawnVehicle', vehicleManagement.SpawnVehicle)
exports('DeleteVehicle', vehicleManagement.DeleteVehicle)
exports('RepairVehicle', vehicleManagement.RepairVehicle)
exports('ModifyVehicle', vehicleManagement.ModifyVehicle)
exports('GetVehicleList', vehicleManagement.GetVehicleList)
exports('GetVehicleClasses', vehicleManagement.GetVehicleClasses)
exports('GetVehiclesByClass', vehicleManagement.GetVehiclesByClass)
exports('SearchVehicles', vehicleManagement.SearchVehicles)
exports('GetNearbyVehicles', vehicleManagement.GetNearbyVehicles)
exports('TeleportToVehicle', vehicleManagement.TeleportToVehicle)
exports('BringVehicle', vehicleManagement.BringVehicle)
exports('LockVehicle', vehicleManagement.LockVehicle)
exports('ToggleEngine', vehicleManagement.ToggleEngine)
exports('ToggleLights', vehicleManagement.ToggleLights)
exports('ToggleSiren', vehicleManagement.ToggleSiren)