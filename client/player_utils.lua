-- Player Utility Functions for Nora Panel
local playerUtils = {}

-- Get player data
function playerUtils.GetPlayerData()
    local playerId = PlayerId()
    local playerPed = PlayerPedId()
    
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local health = GetEntityHealth(playerPed)
    local armor = GetPedArmour(playerPed)
    local money = 0
    local bank = 0
    local job = "unemployed"
    local group = "user"
    
    -- Try to get ESX data if available
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            money = xPlayer.money or 0
            bank = xPlayer.accounts and xPlayer.accounts.bank and xPlayer.accounts.bank.money or 0
            job = xPlayer.job and xPlayer.job.name or "unemployed"
            group = xPlayer.group or "user"
        end
    end
    
    return {
        id = playerId,
        name = GetPlayerName(playerId),
        coords = {x = coords.x, y = coords.y, z = coords.z},
        heading = heading,
        health = health,
        armor = armor,
        money = money,
        bank = bank,
        job = job,
        group = group,
        ping = GetPlayerPing(playerId),
        serverId = GetPlayerServerId(playerId)
    }
end

-- Get all players data
function playerUtils.GetAllPlayersData()
    local players = {}
    local playerList = GetActivePlayers()
    
    for _, playerId in ipairs(playerList) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed and playerPed ~= 0 then
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local health = GetEntityHealth(playerPed)
            local armor = GetPedArmour(playerPed)
            local money = 0
            local bank = 0
            local job = "unemployed"
            local group = "user"
            
            -- Try to get ESX data if available
            if ESX then
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer then
                    money = xPlayer.getMoney()
                    bank = xPlayer.getAccount('bank').money
                    job = xPlayer.getJob().name
                    group = xPlayer.getGroup()
                end
            end
            
            table.insert(players, {
                id = playerId,
                name = GetPlayerName(playerId),
                coords = {x = coords.x, y = coords.y, z = coords.z},
                heading = heading,
                health = health,
                armor = armor,
                money = money,
                bank = bank,
                job = job,
                group = group,
                ping = GetPlayerPing(playerId),
                serverId = GetPlayerServerId(playerId)
            })
        end
    end
    
    return players
end

-- Heal player
function playerUtils.HealPlayer()
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 100)
    
    -- Show notification
    playerUtils.ShowNotification("success", "Healed", "You have been healed")
end

-- Revive player
function playerUtils.RevivePlayer()
    local playerPed = PlayerPedId()
    
    -- Revive the player
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 100)
    
    -- Clear death state
    ClearPedBloodDamage(playerPed)
    ClearPedWetness(playerPed)
    ClearPedEnvDirt(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedLastWeaponDamage(playerPed)
    ClearEntityLastDamageEntity(playerPed)
    
    -- Show notification
    playerUtils.ShowNotification("success", "Revived", "You have been revived")
end

-- Freeze player
function playerUtils.FreezePlayer(freeze)
    local playerPed = PlayerPedId()
    
    if freeze then
        FreezeEntityPosition(playerPed, true)
        playerUtils.ShowNotification("warning", "Frozen", "You have been frozen")
    else
        FreezeEntityPosition(playerPed, false)
        playerUtils.ShowNotification("success", "Unfrozen", "You have been unfrozen")
    end
end

-- Set player health
function playerUtils.SetPlayerHealth(health)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, health)
    
    playerUtils.ShowNotification("info", "Health Set", "Your health has been set to " .. health)
end

-- Set player armor
function playerUtils.SetPlayerArmor(armor)
    local playerPed = PlayerPedId()
    SetPedArmour(playerPed, armor)
    
    playerUtils.ShowNotification("info", "Armor Set", "Your armor has been set to " .. armor)
end

-- Set player money
function playerUtils.SetPlayerMoney(amount, account)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            if account == "bank" then
                xPlayer.setAccountMoney('bank', amount)
            else
                xPlayer.setMoney(amount)
            end
            
            playerUtils.ShowNotification("success", "Money Set", "Your " .. (account or "cash") .. " has been set to $" .. amount)
        end
    end
end

-- Set player job
function playerUtils.SetPlayerJob(job, grade)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            xPlayer.setJob(job, grade or 0)
            
            playerUtils.ShowNotification("success", "Job Set", "Your job has been set to " .. job .. (grade and " (Grade: " .. grade .. ")" or ""))
        end
    end
end

-- Set player group
function playerUtils.SetPlayerGroup(group)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            xPlayer.setGroup(group)
            
            playerUtils.ShowNotification("success", "Group Set", "Your group has been set to " .. group)
        end
    end
end

-- Spectate player
function playerUtils.SpectatePlayer(targetId)
    local targetPed = GetPlayerPed(targetId)
    if not targetPed or targetPed == 0 then
        playerUtils.ShowNotification("error", "Error", "Target player not found")
        return
    end
    
    local playerPed = PlayerPedId()
    local targetCoords = GetEntityCoords(targetPed)
    
    -- Store original position
    playerUtils.originalCoords = GetEntityCoords(playerPed)
    playerUtils.originalHeading = GetEntityHeading(playerPed)
    
    -- Set spectating state
    playerUtils.isSpectating = true
    playerUtils.spectatingTarget = targetId
    
    -- Teleport to target
    SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z + 10.0)
    SetEntityVisible(playerPed, false, false)
    SetEntityCollision(playerPed, false, false)
    FreezeEntityPosition(playerPed, true)
    
    -- Start spectating
    playerUtils.StartSpectating()
    
    playerUtils.ShowNotification("info", "Spectating", "You are now spectating " .. GetPlayerName(targetId))
end

-- Start spectating
function playerUtils.StartSpectating()
    Citizen.CreateThread(function()
        while playerUtils.isSpectating do
            Citizen.Wait(0)
            
            local targetPed = GetPlayerPed(playerUtils.spectatingTarget)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local playerPed = PlayerPedId()
                
                -- Follow target
                SetEntityCoords(playerPed, targetCoords.x, targetCoords.y, targetCoords.z + 10.0)
                
                -- Camera controls
                if IsControlPressed(0, 32) then -- W
                    local heading = GetEntityHeading(playerPed)
                    local forward = GetEntityForwardVector(playerPed)
                    SetEntityCoords(playerPed, targetCoords.x + forward.x * 2.0, targetCoords.y + forward.y * 2.0, targetCoords.z + 10.0)
                elseif IsControlPressed(0, 33) then -- S
                    local heading = GetEntityHeading(playerPed)
                    local forward = GetEntityForwardVector(playerPed)
                    SetEntityCoords(playerPed, targetCoords.x - forward.x * 2.0, targetCoords.y - forward.y * 2.0, targetCoords.z + 10.0)
                elseif IsControlPressed(0, 34) then -- A
                    local heading = GetEntityHeading(playerPed)
                    local right = GetEntityRightVector(playerPed)
                    SetEntityCoords(playerPed, targetCoords.x - right.x * 2.0, targetCoords.y - right.y * 2.0, targetCoords.z + 10.0)
                elseif IsControlPressed(0, 35) then -- D
                    local heading = GetEntityHeading(playerPed)
                    local right = GetEntityRightVector(playerPed)
                    SetEntityCoords(playerPed, targetCoords.x + right.x * 2.0, targetCoords.y + right.y * 2.0, targetCoords.z + 10.0)
                end
            end
            
            -- Check for stop spectating
            if IsControlJustPressed(0, Config.Keys.toggleSpectate) then
                playerUtils.StopSpectating()
            end
        end
    end)
end

-- Stop spectating
function playerUtils.StopSpectating()
    if not playerUtils.isSpectating then
        return
    end
    
    local playerPed = PlayerPedId()
    
    -- Restore original state
    if playerUtils.originalCoords then
        SetEntityCoords(playerPed, playerUtils.originalCoords.x, playerUtils.originalCoords.y, playerUtils.originalCoords.z)
    end
    if playerUtils.originalHeading then
        SetEntityHeading(playerPed, playerUtils.originalHeading)
    end
    
    SetEntityVisible(playerPed, true, false)
    SetEntityCollision(playerPed, true, true)
    FreezeEntityPosition(playerPed, false)
    
    playerUtils.isSpectating = false
    playerUtils.spectatingTarget = nil
    playerUtils.originalCoords = nil
    playerUtils.originalHeading = nil
    
    playerUtils.ShowNotification("info", "Spectating Stopped", "You are no longer spectating")
end

-- Teleport player
function playerUtils.TeleportPlayer(coords, heading)
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
    
    playerUtils.ShowNotification("success", "Teleported", "You have been teleported")
end

-- Teleport to marker
function playerUtils.TeleportToMarker()
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
        
        playerUtils.TeleportPlayer({x = coords.x, y = coords.y, z = groundZ + 1.0})
    else
        playerUtils.ShowNotification("error", "Error", "No waypoint set")
    end
end

-- Show notification
function playerUtils.ShowNotification(type, title, message)
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

-- Get player by server ID
function playerUtils.GetPlayerByServerId(serverId)
    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        if GetPlayerServerId(playerId) == serverId then
            return playerId
        end
    end
    return nil
end

-- Get player by name
function playerUtils.GetPlayerByName(name)
    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        if GetPlayerName(playerId) == name then
            return playerId
        end
    end
    return nil
end

-- Check if player is admin
function playerUtils.IsAdmin()
    return IsPlayerAceAllowed(PlayerId(), "nora.admin")
end

-- Check if player is online
function playerUtils.IsPlayerOnline(playerId)
    local players = GetActivePlayers()
    for _, id in ipairs(players) do
        if id == playerId then
            return true
        end
    end
    return false
end

-- Get player count
function playerUtils.GetPlayerCount()
    return #GetActivePlayers()
end

-- Get max players
function playerUtils.GetMaxPlayers()
    return GetConvarInt('sv_maxclients', 32)
end

-- Export functions
exports('GetPlayerData', playerUtils.GetPlayerData)
exports('GetAllPlayersData', playerUtils.GetAllPlayersData)
exports('HealPlayer', playerUtils.HealPlayer)
exports('RevivePlayer', playerUtils.RevivePlayer)
exports('FreezePlayer', playerUtils.FreezePlayer)
exports('SetPlayerHealth', playerUtils.SetPlayerHealth)
exports('SetPlayerArmor', playerUtils.SetPlayerArmor)
exports('SetPlayerMoney', playerUtils.SetPlayerMoney)
exports('SetPlayerJob', playerUtils.SetPlayerJob)
exports('SetPlayerGroup', playerUtils.SetPlayerGroup)
exports('SpectatePlayer', playerUtils.SpectatePlayer)
exports('StopSpectating', playerUtils.StopSpectating)
exports('TeleportPlayer', playerUtils.TeleportPlayer)
exports('TeleportToMarker', playerUtils.TeleportToMarker)
exports('ShowNotification', playerUtils.ShowNotification)
exports('GetPlayerByServerId', playerUtils.GetPlayerByServerId)
exports('GetPlayerByName', playerUtils.GetPlayerByName)
exports('IsAdmin', playerUtils.IsAdmin)
exports('IsPlayerOnline', playerUtils.IsPlayerOnline)
exports('GetPlayerCount', playerUtils.GetPlayerCount)
exports('GetMaxPlayers', playerUtils.GetMaxPlayers)