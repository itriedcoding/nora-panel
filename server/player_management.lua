-- Advanced Player Management System for Nora Panel
local playerManagement = {}

-- Get player information
function playerManagement.GetPlayerInfo(source, targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return nil
    end
    
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local playerData = exports[GetCurrentResourceName()]:GetPlayerData(targetIdentifier)
    
    if not playerData then
        -- Create player data if it doesn't exist
        local name = GetPlayerName(targetId)
        local steamId = GetPlayerIdentifier(targetId, 0)
        local license = GetPlayerIdentifier(targetId, 1)
        local discord = GetPlayerIdentifier(targetId, 2)
        local xbl = GetPlayerIdentifier(targetId, 3)
        local live = GetPlayerIdentifier(targetId, 4)
        local fivem = GetPlayerIdentifier(targetId, 5)
        local ip = GetPlayerEndpoint(targetId)
        
        exports[GetCurrentResourceName()]:CreatePlayerData(targetIdentifier, name, steamId, license, discord, xbl, live, fivem, ip)
        playerData = exports[GetCurrentResourceName()]:GetPlayerData(targetIdentifier)
    end
    
    -- Get additional runtime data
    local coords = GetEntityCoords(targetPlayer)
    local heading = GetEntityHeading(targetPlayer)
    local health = GetEntityHealth(targetPlayer)
    local armor = GetPedArmour(targetPlayer)
    local money = 0
    local bank = 0
    local job = "unemployed"
    local group = "user"
    
    -- Try to get ESX data if available
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            money = xPlayer.getMoney()
            bank = xPlayer.getAccount('bank').money
            job = xPlayer.getJob().name
            group = xPlayer.getGroup()
        end
    end
    
    return {
        id = targetId,
        identifier = targetIdentifier,
        name = GetPlayerName(targetId),
        steamId = GetPlayerIdentifier(targetId, 0),
        license = GetPlayerIdentifier(targetId, 1),
        discord = GetPlayerIdentifier(targetId, 2),
        xbl = GetPlayerIdentifier(targetId, 3),
        live = GetPlayerIdentifier(targetId, 4),
        fivem = GetPlayerIdentifier(targetId, 5),
        ip = GetPlayerEndpoint(targetId),
        coords = {x = coords.x, y = coords.y, z = coords.z},
        heading = heading,
        health = health,
        armor = armor,
        money = money,
        bank = bank,
        job = job,
        group = group,
        playtime = playerData.playtime or 0,
        adminLevel = playerData.admin_level or 0,
        lastSeen = playerData.last_seen,
        createdAt = playerData.created_at
    }
end

-- Get all online players
function playerManagement.GetOnlinePlayers()
    local players = GetPlayers()
    local onlinePlayers = {}
    
    for _, playerId in ipairs(players) do
        local playerInfo = playerManagement.GetPlayerInfo(nil, playerId)
        if playerInfo then
            table.insert(onlinePlayers, playerInfo)
        end
    end
    
    return onlinePlayers
end

-- Get all players (online and offline)
function playerManagement.GetAllPlayers()
    return exports[GetCurrentResourceName()]:GetAllPlayers()
end

-- Heal player
function playerManagement.HealPlayer(source, targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Heal the player
    SetEntityHealth(targetPlayer, GetEntityMaxHealth(targetPlayer))
    SetPedArmour(targetPlayer, 100)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Player healed",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Health and armor restored",
        GetPlayerEndpoint(source)
    )
    
    -- Notify the player
    TriggerClientEvent('nora:notification', targetId, {
        type = "success",
        title = "Healed",
        message = "You have been healed by an admin",
        duration = 5000
    })
    
    return true, "Player healed successfully"
end

-- Revive player
function playerManagement.RevivePlayer(source, targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Revive the player
    TriggerClientEvent('nora:revive', targetId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Player revived",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Player revived from death",
        GetPlayerEndpoint(source)
    )
    
    -- Notify the player
    TriggerClientEvent('nora:notification', targetId, {
        type = "success",
        title = "Revived",
        message = "You have been revived by an admin",
        duration = 5000
    })
    
    return true, "Player revived successfully"
end

-- Freeze player
function playerManagement.FreezePlayer(source, targetId, freeze)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Freeze/unfreeze the player
    TriggerClientEvent('nora:freeze', targetId, freeze)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        freeze and "Player frozen" or "Player unfrozen",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        freeze and "Player frozen" or "Player unfrozen",
        GetPlayerEndpoint(source)
    )
    
    -- Notify the player
    TriggerClientEvent('nora:notification', targetId, {
        type = freeze and "warning" or "success",
        title = freeze and "Frozen" or "Unfrozen",
        message = freeze and "You have been frozen by an admin" or "You have been unfrozen by an admin",
        duration = 5000
    })
    
    return true, (freeze and "Player frozen" or "Player unfrozen") .. " successfully"
end

-- Set player health
function playerManagement.SetPlayerHealth(source, targetId, health)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Set player health
    SetEntityHealth(targetPlayer, health)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Player health set",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Health set to: " .. health,
        GetPlayerEndpoint(source)
    )
    
    -- Notify the player
    TriggerClientEvent('nora:notification', targetId, {
        type = "info",
        title = "Health Set",
        message = "Your health has been set to " .. health .. " by an admin",
        duration = 5000
    })
    
    return true, "Player health set successfully"
end

-- Set player armor
function playerManagement.SetPlayerArmor(source, targetId, armor)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Set player armor
    SetPedArmour(targetPlayer, armor)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Player armor set",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Armor set to: " .. armor,
        GetPlayerEndpoint(source)
    )
    
    -- Notify the player
    TriggerClientEvent('nora:notification', targetId, {
        type = "info",
        title = "Armor Set",
        message = "Your armor has been set to " .. armor .. " by an admin",
        duration = 5000
    })
    
    return true, "Player armor set successfully"
end

-- Set player money
function playerManagement.SetPlayerMoney(source, targetId, amount)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to set money using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            xPlayer.setMoney(amount)
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "player",
                "Player money set",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Money set to: $" .. amount,
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "success",
                title = "Money Set",
                message = "Your money has been set to $" .. amount .. " by an admin",
                duration = 5000
            })
            
            return true, "Player money set successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Set player bank
function playerManagement.SetPlayerBank(source, targetId, amount)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to set bank using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            xPlayer.setAccountMoney('bank', amount)
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "player",
                "Player bank set",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Bank set to: $" .. amount,
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "success",
                title = "Bank Set",
                message = "Your bank has been set to $" .. amount .. " by an admin",
                duration = 5000
            })
            
            return true, "Player bank set successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Set player job
function playerManagement.SetPlayerJob(source, targetId, job, grade)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to set job using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            xPlayer.setJob(job, grade or 0)
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "player",
                "Player job set",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Job set to: " .. job .. (grade and " (Grade: " .. grade .. ")" or ""),
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "success",
                title = "Job Set",
                message = "Your job has been set to " .. job .. (grade and " (Grade: " .. grade .. ")" or "") .. " by an admin",
                duration = 5000
            })
            
            return true, "Player job set successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Set player group
function playerManagement.SetPlayerGroup(source, targetId, group)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to set group using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            xPlayer.setGroup(group)
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "player",
                "Player group set",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Group set to: " .. group,
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "success",
                title = "Group Set",
                message = "Your group has been set to " .. group .. " by an admin",
                duration = 5000
            })
            
            return true, "Player group set successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Spectate player
function playerManagement.SpectatePlayer(source, targetId)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Start spectating
    TriggerClientEvent('nora:spectate', source, targetId)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Player spectating",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Started spectating player",
        GetPlayerEndpoint(source)
    )
    
    return true, "Started spectating player"
end

-- Stop spectating
function playerManagement.StopSpectating(source)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Stop spectating
    TriggerClientEvent('nora:stopSpectate', source)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "player",
        "Stop spectating",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Stopped spectating",
        GetPlayerEndpoint(source)
    )
    
    return true, "Stopped spectating"
end

-- Export functions
exports('GetPlayerInfo', playerManagement.GetPlayerInfo)
exports('GetOnlinePlayers', playerManagement.GetOnlinePlayers)
exports('GetAllPlayers', playerManagement.GetAllPlayers)
exports('HealPlayer', playerManagement.HealPlayer)
exports('RevivePlayer', playerManagement.RevivePlayer)
exports('FreezePlayer', playerManagement.FreezePlayer)
exports('SetPlayerHealth', playerManagement.SetPlayerHealth)
exports('SetPlayerArmor', playerManagement.SetPlayerArmor)
exports('SetPlayerMoney', playerManagement.SetPlayerMoney)
exports('SetPlayerBank', playerManagement.SetPlayerBank)
exports('SetPlayerJob', playerManagement.SetPlayerJob)
exports('SetPlayerGroup', playerManagement.SetPlayerGroup)
exports('SpectatePlayer', playerManagement.SpectatePlayer)
exports('StopSpectating', playerManagement.StopSpectating)