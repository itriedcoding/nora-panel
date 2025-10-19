-- Advanced Weapon Management System for Nora Panel
local weaponManagement = {}

-- Give weapon to player
function weaponManagement.GiveWeapon(source, targetId, weaponHash, ammo)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Give weapon on client side
    TriggerClientEvent('nora:giveWeapon', targetId, weaponHash, ammo or 250)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Weapon given",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash) .. " | Ammo: " .. (ammo or 250),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weapon given successfully"
end

-- Remove weapon from player
function weaponManagement.RemoveWeapon(source, targetId, weaponHash)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Remove weapon on client side
    TriggerClientEvent('nora:removeWeapon', targetId, weaponHash)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Weapon removed",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weapon removed successfully"
end

-- Remove all weapons from player
function weaponManagement.RemoveAllWeapons(source, targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Remove all weapons on client side
    TriggerClientEvent('nora:removeAllWeapons', targetId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "All weapons removed",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "All weapons removed from player",
        GetPlayerEndpoint(source)
    )
    
    return true, "All weapons removed successfully"
end

-- Give ammo to player
function weaponManagement.GiveAmmo(source, targetId, weaponHash, ammo)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Give ammo on client side
    TriggerClientEvent('nora:giveAmmo', targetId, weaponHash, ammo)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Ammo given",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash) .. " | Ammo: " .. ammo,
        GetPlayerEndpoint(source)
    )
    
    return true, "Ammo given successfully"
end

-- Get weapon list
function weaponManagement.GetWeaponList()
    local weapons = {}
    
    -- Get all weapon hashes
    for i = 0, GetNumWeaponComponents() - 1 do
        local weaponHash = GetHashKey(GetWeaponComponentFromIndex(i))
        local name = GetWeaponDisplayNameFromHash(weaponHash)
        local group = GetWeaponTypeFromHash(weaponHash)
        local groupName = GetWeaponTypeDisplayName(group)
        
        table.insert(weapons, {
            hash = weaponHash,
            name = name,
            group = group,
            groupName = groupName
        })
    end
    
    return weapons
end

-- Get weapon groups
function weaponManagement.GetWeaponGroups()
    local groups = {}
    
    for i = 0, 15 do
        local groupName = GetWeaponTypeDisplayName(i)
        if groupName and groupName ~= "NULL" then
            table.insert(groups, {
                id = i,
                name = groupName
            })
        end
    end
    
    return groups
end

-- Get weapons by group
function weaponManagement.GetWeaponsByGroup(groupId)
    local weapons = {}
    
    for i = 0, GetNumWeaponComponents() - 1 do
        local weaponHash = GetHashKey(GetWeaponComponentFromIndex(i))
        local group = GetWeaponTypeFromHash(weaponHash)
        
        if group == groupId then
            local name = GetWeaponDisplayNameFromHash(weaponHash)
            local groupName = GetWeaponTypeDisplayName(group)
            
            table.insert(weapons, {
                hash = weaponHash,
                name = name,
                group = group,
                groupName = groupName
            })
        end
    end
    
    return weapons
end

-- Search weapons
function weaponManagement.SearchWeapons(query)
    local weapons = {}
    local queryLower = string.lower(query)
    
    for i = 0, GetNumWeaponComponents() - 1 do
        local weaponHash = GetHashKey(GetWeaponComponentFromIndex(i))
        local name = GetWeaponDisplayNameFromHash(weaponHash)
        local group = GetWeaponTypeFromHash(weaponHash)
        local groupName = GetWeaponTypeDisplayName(group)
        
        if string.find(string.lower(name), queryLower) or string.find(string.lower(groupName), queryLower) then
            table.insert(weapons, {
                hash = weaponHash,
                name = name,
                group = group,
                groupName = groupName
            })
        end
    end
    
    return weapons
end

-- Get player weapons
function weaponManagement.GetPlayerWeapons(targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return {}
    end
    
    local weapons = {}
    
    -- Get all weapons the player has
    for i = 0, GetNumWeaponComponents() - 1 do
        local weaponHash = GetHashKey(GetWeaponComponentFromIndex(i))
        if HasPedGotWeapon(targetPlayer, weaponHash, false) then
            local name = GetWeaponDisplayNameFromHash(weaponHash)
            local group = GetWeaponTypeFromHash(weaponHash)
            local groupName = GetWeaponTypeDisplayName(group)
            local ammo = GetAmmoInPedWeapon(targetPlayer, weaponHash)
            local maxAmmo = GetMaxAmmoInClip(targetPlayer, weaponHash, true)
            
            table.insert(weapons, {
                hash = weaponHash,
                name = name,
                group = group,
                groupName = groupName,
                ammo = ammo,
                maxAmmo = maxAmmo
            })
        end
    end
    
    return weapons
end

-- Set weapon ammo
function weaponManagement.SetWeaponAmmo(source, targetId, weaponHash, ammo)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Set weapon ammo on client side
    TriggerClientEvent('nora:setWeaponAmmo', targetId, weaponHash, ammo)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Weapon ammo set",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash) .. " | Ammo: " .. ammo,
        GetPlayerEndpoint(source)
    )
    
    return true, "Weapon ammo set successfully"
end

-- Give weapon component
function weaponManagement.GiveWeaponComponent(source, targetId, weaponHash, componentHash)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Give weapon component on client side
    TriggerClientEvent('nora:giveWeaponComponent', targetId, weaponHash, componentHash)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Weapon component given",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash) .. " | Component: " .. GetWeaponComponentDisplayName(componentHash),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weapon component given successfully"
end

-- Remove weapon component
function weaponManagement.RemoveWeaponComponent(source, targetId, weaponHash, componentHash)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Remove weapon component on client side
    TriggerClientEvent('nora:removeWeaponComponent', targetId, weaponHash, componentHash)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weapon",
        "Weapon component removed",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weapon: " .. GetWeaponDisplayNameFromHash(weaponHash) .. " | Component: " .. GetWeaponComponentDisplayName(componentHash),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weapon component removed successfully"
end

-- Get weapon components
function weaponManagement.GetWeaponComponents(weaponHash)
    local components = {}
    
    for i = 0, GetNumWeaponComponents(weaponHash) - 1 do
        local componentHash = GetHashKey(GetWeaponComponentFromIndex(weaponHash, i))
        local name = GetWeaponComponentDisplayName(componentHash)
        
        table.insert(components, {
            hash = componentHash,
            name = name
        })
    end
    
    return components
end

-- Export functions
exports('GiveWeapon', weaponManagement.GiveWeapon)
exports('RemoveWeapon', weaponManagement.RemoveWeapon)
exports('RemoveAllWeapons', weaponManagement.RemoveAllWeapons)
exports('GiveAmmo', weaponManagement.GiveAmmo)
exports('GetWeaponList', weaponManagement.GetWeaponList)
exports('GetWeaponGroups', weaponManagement.GetWeaponGroups)
exports('GetWeaponsByGroup', weaponManagement.GetWeaponsByGroup)
exports('SearchWeapons', weaponManagement.SearchWeapons)
exports('GetPlayerWeapons', weaponManagement.GetPlayerWeapons)
exports('SetWeaponAmmo', weaponManagement.SetWeaponAmmo)
exports('GiveWeaponComponent', weaponManagement.GiveWeaponComponent)
exports('RemoveWeaponComponent', weaponManagement.RemoveWeaponComponent)
exports('GetWeaponComponents', weaponManagement.GetWeaponComponents)