-- Advanced Ban System for Nora Panel
local banSystem = {}

-- Ban a player
function banSystem.BanPlayer(source, targetId, reason, duration, permanent)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIP = GetPlayerEndpoint(targetId)
    
    -- Get additional identifiers
    local steamId = GetPlayerIdentifier(targetId, 0)
    local license = GetPlayerIdentifier(targetId, 1)
    local discord = GetPlayerIdentifier(targetId, 2)
    local xbl = GetPlayerIdentifier(targetId, 3)
    local live = GetPlayerIdentifier(targetId, 4)
    local fivem = GetPlayerIdentifier(targetId, 5)
    
    -- Check if player is already banned
    local existingBan = exports[GetCurrentResourceName()]:GetBan(targetIdentifier)
    if existingBan then
        return false, "Player is already banned"
    end
    
    -- Calculate expiry time
    local expiresAt = nil
    if not permanent and duration then
        expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (duration * 24 * 60 * 60))
    end
    
    -- Add ban to database
    exports[GetCurrentResourceName()]:AddBan(
        targetIdentifier,
        targetName,
        reason,
        adminIdentifier,
        expiresAt,
        permanent or false,
        targetIP,
        steamId,
        license,
        discord
    )
    
    -- Log the ban action
    exports[GetCurrentResourceName()]:AddLog(
        "ban",
        "Player banned",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Reason: " .. reason .. (duration and " | Duration: " .. duration .. " days" or " | Permanent"),
        GetPlayerEndpoint(source)
    )
    
    -- Kick the player
    DropPlayer(targetId, "You have been banned from the server.\nReason: " .. reason .. (duration and "\nDuration: " .. duration .. " days" or "\nDuration: Permanent"))
    
    -- Notify admins
    local adminPlayers = GetPlayers()
    for _, adminId in ipairs(adminPlayers) do
        if IsPlayerAceAllowed(adminId, "nora.admin") then
            TriggerClientEvent('nora:notification', adminId, {
                type = "info",
                title = "Player Banned",
                message = targetName .. " has been banned by " .. adminName,
                duration = 5000
            })
        end
    end
    
    return true, "Player banned successfully"
end

-- Unban a player
function banSystem.UnbanPlayer(source, banId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Remove ban from database
    exports[GetCurrentResourceName()]:RemoveBan(banId)
    
    -- Log the unban action
    exports[GetCurrentResourceName()]:AddLog(
        "ban",
        "Player unbanned",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Ban ID: " .. banId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Player unbanned successfully"
end

-- Check if player is banned
function banSystem.IsPlayerBanned(identifier)
    local ban = exports[GetCurrentResourceName()]:GetBan(identifier)
    if ban then
        return true, ban
    end
    return false, nil
end

-- Get all bans
function banSystem.GetAllBans()
    return exports[GetCurrentResourceName()]:GetAllBans()
end

-- Get ban statistics
function banSystem.GetBanStats()
    local bans = exports[GetCurrentResourceName()]:GetAllBans()
    local stats = {
        total = 0,
        active = 0,
        permanent = 0,
        temporary = 0,
        today = 0,
        thisWeek = 0,
        thisMonth = 0
    }
    
    local today = os.date('%Y-%m-%d')
    local weekAgo = os.date('%Y-%m-%d', os.time() - (7 * 24 * 60 * 60))
    local monthAgo = os.date('%Y-%m-%d', os.time() - (30 * 24 * 60 * 60))
    
    for _, ban in ipairs(bans) do
        stats.total = stats.total + 1
        
        if ban.active then
            stats.active = stats.active + 1
        end
        
        if ban.permanent then
            stats.permanent = stats.permanent + 1
        else
            stats.temporary = stats.temporary + 1
        end
        
        local banDate = os.date('%Y-%m-%d', ban.banned_at)
        if banDate == today then
            stats.today = stats.today + 1
        end
        if banDate >= weekAgo then
            stats.thisWeek = stats.thisWeek + 1
        end
        if banDate >= monthAgo then
            stats.thisMonth = stats.thisMonth + 1
        end
    end
    
    return stats
end

-- Clean expired bans
function banSystem.CleanExpiredBans()
    MySQL.Async.execute('UPDATE nora_bans SET active = 0 WHERE expires_at IS NOT NULL AND expires_at < NOW() AND active = 1', {})
    print("^2[Nora Panel]^7 Expired bans cleaned up")
end

-- Ban by IP
function banSystem.BanIP(source, ip, reason, duration, permanent)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Calculate expiry time
    local expiresAt = nil
    if not permanent and duration then
        expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (duration * 24 * 60 * 60))
    end
    
    -- Add IP ban to database
    exports[GetCurrentResourceName()]:AddBan(
        ip,
        "IP Ban",
        reason,
        adminIdentifier,
        expiresAt,
        permanent or false,
        ip,
        nil,
        nil,
        nil
    )
    
    -- Log the IP ban action
    exports[GetCurrentResourceName()]:AddLog(
        "ban",
        "IP banned",
        ip,
        "IP Ban",
        adminIdentifier,
        adminName,
        "Reason: " .. reason .. (duration and " | Duration: " .. duration .. " days" or " | Permanent"),
        GetPlayerEndpoint(source)
    )
    
    -- Kick all players with this IP
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if GetPlayerEndpoint(playerId) == ip then
            DropPlayer(playerId, "Your IP has been banned from the server.\nReason: " .. reason)
        end
    end
    
    return true, "IP banned successfully"
end

-- Ban by Steam ID
function banSystem.BanSteamID(source, steamId, reason, duration, permanent)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Calculate expiry time
    local expiresAt = nil
    if not permanent and duration then
        expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (duration * 24 * 60 * 60))
    end
    
    -- Add Steam ID ban to database
    exports[GetCurrentResourceName()]:AddBan(
        steamId,
        "Steam ID Ban",
        reason,
        adminIdentifier,
        expiresAt,
        permanent or false,
        nil,
        steamId,
        nil,
        nil
    )
    
    -- Log the Steam ID ban action
    exports[GetCurrentResourceName()]:AddLog(
        "ban",
        "Steam ID banned",
        steamId,
        "Steam ID Ban",
        adminIdentifier,
        adminName,
        "Reason: " .. reason .. (duration and " | Duration: " .. duration .. " days" or " | Permanent"),
        GetPlayerEndpoint(source)
    )
    
    -- Kick all players with this Steam ID
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if GetPlayerIdentifier(playerId, 0) == steamId then
            DropPlayer(playerId, "Your Steam ID has been banned from the server.\nReason: " .. reason)
        end
    end
    
    return true, "Steam ID banned successfully"
end

-- Export functions
exports('BanPlayer', banSystem.BanPlayer)
exports('UnbanPlayer', banSystem.UnbanPlayer)
exports('IsPlayerBanned', banSystem.IsPlayerBanned)
exports('GetAllBans', banSystem.GetAllBans)
exports('GetBanStats', banSystem.GetBanStats)
exports('CleanExpiredBans', banSystem.CleanExpiredBans)
exports('BanIP', banSystem.BanIP)
exports('BanSteamID', banSystem.BanSteamID)

-- Clean expired bans every hour
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- 1 hour
        banSystem.CleanExpiredBans()
    end
end)