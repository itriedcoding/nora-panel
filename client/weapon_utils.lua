-- Weapon Utility Functions for Nora Panel
local weaponUtils = {}

-- Give weapon
function weaponUtils.GiveWeapon(weaponHash, ammo)
    local playerPed = PlayerPedId()
    
    -- Check if weapon is valid
    if not IsWeaponValid(weaponHash) then
        weaponUtils.ShowNotification("error", "Error", "Invalid weapon")
        return false
    end
    
    -- Give weapon
    GiveWeaponToPed(playerPed, weaponHash, ammo or 250, false, true)
    
    weaponUtils.ShowNotification("success", "Weapon Given", "Weapon given successfully")
    
    return true
end

-- Remove weapon
function weaponUtils.RemoveWeapon(weaponHash)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Remove weapon
    RemoveWeaponFromPed(playerPed, weaponHash)
    
    weaponUtils.ShowNotification("success", "Weapon Removed", "Weapon removed successfully")
    
    return true
end

-- Remove all weapons
function weaponUtils.RemoveAllWeapons()
    local playerPed = PlayerPedId()
    
    -- Remove all weapons
    RemoveAllPedWeapons(playerPed, true)
    
    weaponUtils.ShowNotification("success", "All Weapons Removed", "All weapons removed successfully")
    
    return true
end

-- Give ammo
function weaponUtils.GiveAmmo(weaponHash, ammo)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Give ammo
    SetPedAmmo(playerPed, weaponHash, ammo)
    
    weaponUtils.ShowNotification("success", "Ammo Given", "Ammo given successfully")
    
    return true
end

-- Get weapon list
function weaponUtils.GetWeaponList()
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
function weaponUtils.GetWeaponGroups()
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
function weaponUtils.GetWeaponsByGroup(groupId)
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
function weaponUtils.SearchWeapons(query)
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
function weaponUtils.GetPlayerWeapons()
    local playerPed = PlayerPedId()
    local weapons = {}
    
    -- Get all weapons the player has
    for i = 0, GetNumWeaponComponents() - 1 do
        local weaponHash = GetHashKey(GetWeaponComponentFromIndex(i))
        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local name = GetWeaponDisplayNameFromHash(weaponHash)
            local group = GetWeaponTypeFromHash(weaponHash)
            local groupName = GetWeaponTypeDisplayName(group)
            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
            local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, true)
            
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
function weaponUtils.SetWeaponAmmo(weaponHash, ammo)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Set ammo
    SetPedAmmo(playerPed, weaponHash, ammo)
    
    weaponUtils.ShowNotification("success", "Ammo Set", "Ammo set to " .. ammo)
    
    return true
end

-- Give weapon component
function weaponUtils.GiveWeaponComponent(weaponHash, componentHash)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Check if component is valid for weapon
    if not HasWeaponGotWeaponComponent(playerPed, weaponHash, componentHash) then
        weaponUtils.ShowNotification("error", "Error", "Invalid component for this weapon")
        return false
    end
    
    -- Give component
    GiveWeaponComponentToPed(playerPed, weaponHash, componentHash)
    
    weaponUtils.ShowNotification("success", "Component Given", "Weapon component given successfully")
    
    return true
end

-- Remove weapon component
function weaponUtils.RemoveWeaponComponent(weaponHash, componentHash)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Check if player has component
    if not HasPedGotWeaponComponent(playerPed, weaponHash, componentHash) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this component")
        return false
    end
    
    -- Remove component
    RemoveWeaponComponentFromPed(playerPed, weaponHash, componentHash)
    
    weaponUtils.ShowNotification("success", "Component Removed", "Weapon component removed successfully")
    
    return true
end

-- Get weapon components
function weaponUtils.GetWeaponComponents(weaponHash)
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

-- Get weapon info
function weaponUtils.GetWeaponInfo(weaponHash)
    local name = GetWeaponDisplayNameFromHash(weaponHash)
    local group = GetWeaponTypeFromHash(weaponHash)
    local groupName = GetWeaponTypeDisplayName(group)
    local damage = GetWeaponDamage(weaponHash, 0)
    local range = GetWeaponRange(weaponHash)
    local accuracy = GetWeaponAccuracy(weaponHash)
    local recoil = GetWeaponRecoil(weaponHash)
    local reloadTime = GetWeaponReloadTime(weaponHash)
    
    return {
        hash = weaponHash,
        name = name,
        group = group,
        groupName = groupName,
        damage = damage,
        range = range,
        accuracy = accuracy,
        recoil = recoil,
        reloadTime = reloadTime
    }
end

-- Get current weapon
function weaponUtils.GetCurrentWeapon()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    
    if weaponHash ~= GetHashKey("WEAPON_UNARMED") then
        return weaponUtils.GetWeaponInfo(weaponHash)
    end
    
    return nil
end

-- Equip weapon
function weaponUtils.EquipWeapon(weaponHash)
    local playerPed = PlayerPedId()
    
    -- Check if player has weapon
    if not HasPedGotWeapon(playerPed, weaponHash, false) then
        weaponUtils.ShowNotification("error", "Error", "Player doesn't have this weapon")
        return false
    end
    
    -- Equip weapon
    SetCurrentPedWeapon(playerPed, weaponHash, true)
    
    weaponUtils.ShowNotification("success", "Weapon Equipped", "Weapon equipped")
    
    return true
end

-- Get weapon damage
function weaponUtils.GetWeaponDamage(weaponHash)
    return GetWeaponDamage(weaponHash, 0)
end

-- Get weapon range
function weaponUtils.GetWeaponRange(weaponHash)
    return GetWeaponRange(weaponHash)
end

-- Get weapon accuracy
function weaponUtils.GetWeaponAccuracy(weaponHash)
    return GetWeaponAccuracy(weaponHash)
end

-- Get weapon recoil
function weaponUtils.GetWeaponRecoil(weaponHash)
    return GetWeaponRecoil(weaponHash)
end

-- Get weapon reload time
function weaponUtils.GetWeaponReloadTime(weaponHash)
    return GetWeaponReloadTime(weaponHash)
end

-- Show notification
function weaponUtils.ShowNotification(type, title, message)
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
exports('GiveWeapon', weaponUtils.GiveWeapon)
exports('RemoveWeapon', weaponUtils.RemoveWeapon)
exports('RemoveAllWeapons', weaponUtils.RemoveAllWeapons)
exports('GiveAmmo', weaponUtils.GiveAmmo)
exports('GetWeaponList', weaponUtils.GetWeaponList)
exports('GetWeaponGroups', weaponUtils.GetWeaponGroups)
exports('GetWeaponsByGroup', weaponUtils.GetWeaponsByGroup)
exports('SearchWeapons', weaponUtils.SearchWeapons)
exports('GetPlayerWeapons', weaponUtils.GetPlayerWeapons)
exports('SetWeaponAmmo', weaponUtils.SetWeaponAmmo)
exports('GiveWeaponComponent', weaponUtils.GiveWeaponComponent)
exports('RemoveWeaponComponent', weaponUtils.RemoveWeaponComponent)
exports('GetWeaponComponents', weaponUtils.GetWeaponComponents)
exports('GetWeaponInfo', weaponUtils.GetWeaponInfo)
exports('GetCurrentWeapon', weaponUtils.GetCurrentWeapon)
exports('EquipWeapon', weaponUtils.EquipWeapon)
exports('GetWeaponDamage', weaponUtils.GetWeaponDamage)
exports('GetWeaponRange', weaponUtils.GetWeaponRange)
exports('GetWeaponAccuracy', weaponUtils.GetWeaponAccuracy)
exports('GetWeaponRecoil', weaponUtils.GetWeaponRecoil)
exports('GetWeaponReloadTime', weaponUtils.GetWeaponReloadTime)