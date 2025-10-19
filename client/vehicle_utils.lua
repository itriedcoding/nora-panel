-- Vehicle Utility Functions for Nora Panel
local vehicleUtils = {}

-- Spawn vehicle
function vehicleUtils.SpawnVehicle(model, coords, heading)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Check if model is valid
    if not IsModelValid(model) then
        vehicleUtils.ShowNotification("error", "Error", "Invalid vehicle model")
        return nil
    end
    
    -- Request model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    
    -- Set vehicle properties
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetModelAsNoLongerNeeded(model)
    
    -- Put player in vehicle
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    
    vehicleUtils.ShowNotification("success", "Vehicle Spawned", "Vehicle spawned successfully")
    
    return vehicle
end

-- Delete vehicle
function vehicleUtils.DeleteVehicle(vehicleId)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
    
    -- If player is in the vehicle, remove them
    if playerVehicle == vehicleId then
        TaskLeaveVehicle(playerPed, vehicleId, 0)
        Citizen.Wait(1000)
    end
    
    -- Delete vehicle
    DeleteEntity(vehicleId)
    
    vehicleUtils.ShowNotification("success", "Vehicle Deleted", "Vehicle deleted successfully")
    
    return true
end

-- Repair vehicle
function vehicleUtils.RepairVehicle(vehicleId)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    -- Repair vehicle
    SetVehicleFixed(vehicleId)
    SetVehicleDeformationFixed(vehicleId)
    SetVehicleUndriveable(vehicleId, false)
    SetVehicleEngineOn(vehicleId, true, true, false)
    SetVehicleEngineHealth(vehicleId, 1000.0)
    SetVehicleBodyHealth(vehicleId, 1000.0)
    SetVehiclePetrolTankHealth(vehicleId, 1000.0)
    SetVehicleOilLevel(vehicleId, 1000.0)
    SetVehicleFuelLevel(vehicleId, 100.0)
    
    vehicleUtils.ShowNotification("success", "Vehicle Repaired", "Vehicle repaired successfully")
    
    return true
end

-- Modify vehicle
function vehicleUtils.ModifyVehicle(vehicleId, modifications)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    -- Apply modifications
    for modType, modIndex in pairs(modifications) do
        if modType == "color" then
            SetVehicleColours(vehicleId, modIndex.primary or 0, modIndex.secondary or 0)
        elseif modType == "wheels" then
            SetVehicleWheelType(vehicleId, modIndex.type or 0)
            SetVehicleMod(vehicleId, 23, modIndex.index or 0, false)
        elseif modType == "engine" then
            SetVehicleMod(vehicleId, 11, modIndex, false)
        elseif modType == "transmission" then
            SetVehicleMod(vehicleId, 13, modIndex, false)
        elseif modType == "brakes" then
            SetVehicleMod(vehicleId, 12, modIndex, false)
        elseif modType == "suspension" then
            SetVehicleMod(vehicleId, 15, modIndex, false)
        elseif modType == "armor" then
            SetVehicleMod(vehicleId, 16, modIndex, false)
        elseif modType == "turbo" then
            ToggleVehicleMod(vehicleId, 18, modIndex)
        elseif modType == "xenon" then
            ToggleVehicleMod(vehicleId, 22, modIndex)
        elseif modType == "neon" then
            SetVehicleNeonLightEnabled(vehicleId, 0, modIndex.left)
            SetVehicleNeonLightEnabled(vehicleId, 1, modIndex.right)
            SetVehicleNeonLightEnabled(vehicleId, 2, modIndex.front)
            SetVehicleNeonLightEnabled(vehicleId, 3, modIndex.back)
        elseif modType == "neonColor" then
            SetVehicleNeonLightsColour(vehicleId, modIndex.r, modIndex.g, modIndex.b)
        elseif modType == "plate" then
            SetVehicleNumberPlateText(vehicleId, modIndex.text or "NORA")
        elseif modType == "plateType" then
            SetVehicleNumberPlateTextIndex(vehicleId, modIndex)
        end
    end
    
    vehicleUtils.ShowNotification("success", "Vehicle Modified", "Vehicle modified successfully")
    
    return true
end

-- Get vehicle list
function vehicleUtils.GetVehicleList()
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
function vehicleUtils.GetVehicleClasses()
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
function vehicleUtils.GetVehiclesByClass(classId)
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
function vehicleUtils.SearchVehicles(query)
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
function vehicleUtils.GetNearbyVehicles(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = {}
    
    -- Get all vehicles in radius
    local vehicleList = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicleList) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
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
function vehicleUtils.TeleportToVehicle(vehicleId)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    local playerPed = PlayerPedId()
    local vehicleCoords = GetEntityCoords(vehicleId)
    local vehicleHeading = GetEntityHeading(vehicleId)
    
    -- Teleport player to vehicle
    SetEntityCoords(playerPed, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 2.0)
    SetEntityHeading(playerPed, vehicleHeading)
    
    vehicleUtils.ShowNotification("success", "Teleported", "Teleported to vehicle")
    
    return true
end

-- Bring vehicle
function vehicleUtils.BringVehicle(vehicleId)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Teleport vehicle to player
    SetEntityCoords(vehicleId, playerCoords.x, playerCoords.y, playerCoords.z)
    SetEntityHeading(vehicleId, playerHeading)
    
    vehicleUtils.ShowNotification("success", "Vehicle Brought", "Vehicle brought to you")
    
    return true
end

-- Lock vehicle
function vehicleUtils.LockVehicle(vehicleId, lock)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    if lock then
        SetVehicleDoorsLocked(vehicleId, 2)
        vehicleUtils.ShowNotification("info", "Vehicle Locked", "Vehicle locked")
    else
        SetVehicleDoorsLocked(vehicleId, 1)
        vehicleUtils.ShowNotification("info", "Vehicle Unlocked", "Vehicle unlocked")
    end
    
    return true
end

-- Toggle engine
function vehicleUtils.ToggleEngine(vehicleId, start)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    if start then
        SetVehicleEngineOn(vehicleId, true, true, false)
        vehicleUtils.ShowNotification("info", "Engine Started", "Engine started")
    else
        SetVehicleEngineOn(vehicleId, false, true, false)
        vehicleUtils.ShowNotification("info", "Engine Stopped", "Engine stopped")
    end
    
    return true
end

-- Toggle lights
function vehicleUtils.ToggleLights(vehicleId, on)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    if on then
        SetVehicleLights(vehicleId, 2)
        vehicleUtils.ShowNotification("info", "Lights On", "Lights turned on")
    else
        SetVehicleLights(vehicleId, 0)
        vehicleUtils.ShowNotification("info", "Lights Off", "Lights turned off")
    end
    
    return true
end

-- Toggle siren
function vehicleUtils.ToggleSiren(vehicleId, on)
    if not DoesEntityExist(vehicleId) then
        vehicleUtils.ShowNotification("error", "Error", "Vehicle not found")
        return false
    end
    
    if on then
        SetVehicleSiren(vehicleId, true)
        vehicleUtils.ShowNotification("info", "Siren On", "Siren turned on")
    else
        SetVehicleSiren(vehicleId, false)
        vehicleUtils.ShowNotification("info", "Siren Off", "Siren turned off")
    end
    
    return true
end

-- Get vehicle info
function vehicleUtils.GetVehicleInfo(vehicleId)
    if not DoesEntityExist(vehicleId) then
        return nil
    end
    
    local model = GetEntityModel(vehicleId)
    local name = GetDisplayNameFromVehicleModel(model)
    local class = GetVehicleClassFromName(model)
    local className = GetVehicleClassDisplayName(class)
    local coords = GetEntityCoords(vehicleId)
    local heading = GetEntityHeading(vehicleId)
    local health = GetEntityHealth(vehicleId)
    local maxHealth = GetEntityMaxHealth(vehicleId)
    local fuel = GetVehicleFuelLevel(vehicleId)
    local engineHealth = GetVehicleEngineHealth(vehicleId)
    local bodyHealth = GetVehicleBodyHealth(vehicleId)
    local tankHealth = GetVehiclePetrolTankHealth(vehicleId)
    
    return {
        id = vehicleId,
        model = model,
        name = name,
        class = class,
        className = className,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        heading = heading,
        health = health,
        maxHealth = maxHealth,
        fuel = fuel,
        engineHealth = engineHealth,
        bodyHealth = bodyHealth,
        tankHealth = tankHealth,
        locked = GetVehicleDoorLockStatus(vehicleId),
        engine = GetIsVehicleEngineRunning(vehicleId),
        lights = GetVehicleLightsState(vehicleId),
        siren = IsVehicleSirenOn(vehicleId)
    }
end

-- Get player vehicle
function vehicleUtils.GetPlayerVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        return vehicleUtils.GetVehicleInfo(vehicle)
    end
    
    return nil
end

-- Show notification
function vehicleUtils.ShowNotification(type, title, message)
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
exports('SpawnVehicle', vehicleUtils.SpawnVehicle)
exports('DeleteVehicle', vehicleUtils.DeleteVehicle)
exports('RepairVehicle', vehicleUtils.RepairVehicle)
exports('ModifyVehicle', vehicleUtils.ModifyVehicle)
exports('GetVehicleList', vehicleUtils.GetVehicleList)
exports('GetVehicleClasses', vehicleUtils.GetVehicleClasses)
exports('GetVehiclesByClass', vehicleUtils.GetVehiclesByClass)
exports('SearchVehicles', vehicleUtils.SearchVehicles)
exports('GetNearbyVehicles', vehicleUtils.GetNearbyVehicles)
exports('TeleportToVehicle', vehicleUtils.TeleportToVehicle)
exports('BringVehicle', vehicleUtils.BringVehicle)
exports('LockVehicle', vehicleUtils.LockVehicle)
exports('ToggleEngine', vehicleUtils.ToggleEngine)
exports('ToggleLights', vehicleUtils.ToggleLights)
exports('ToggleSiren', vehicleUtils.ToggleSiren)
exports('GetVehicleInfo', vehicleUtils.GetVehicleInfo)
exports('GetPlayerVehicle', vehicleUtils.GetPlayerVehicle)