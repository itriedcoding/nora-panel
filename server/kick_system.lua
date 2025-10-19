-- Advanced Kick System for Nora Panel
local kickSystem = {}

-- Kick a player
function kickSystem.KickPlayer(source, targetId, reason)
    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIP = GetPlayerEndpoint(targetId)
    
    -- Add kick to database
    exports[GetCurrentResourceName()]:AddKick(
        targetIdentifier,
        targetName,
        reason,
        adminIdentifier,
        targetIP
    )
    
    -- Log the kick action
    exports[GetCurrentResourceName()]:AddLog(
        "kick",
        "Player kicked",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Reason: " .. reason,
        GetPlayerEndpoint(source)
    )
    
    -- Kick the player
    DropPlayer(targetId, "You have been kicked from the server.\nReason: " .. reason)
    
    -- Notify admins
    local adminPlayers = GetPlayers()
    for _, adminId in ipairs(adminPlayers) do
        if IsPlayerAceAllowed(adminId, "nora.admin") then
            TriggerClientEvent('nora:notification', adminId, {
                type = "info",
                title = "Player Kicked",
                message = targetName .. " has been kicked by " .. adminName,
                duration = 5000
            })
        end
    end
    
    return true, "Player kicked successfully"
end

-- Kick all players
function kickSystem.KickAllPlayers(source, reason)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local players = GetPlayers()
    local kickedCount = 0
    
    for _, playerId in ipairs(players) do
        if playerId ~= source then
            local targetIdentifier = GetPlayerIdentifier(playerId)
            local targetName = GetPlayerName(playerId)
            local targetIP = GetPlayerEndpoint(playerId)
            
            -- Add kick to database
            exports[GetCurrentResourceName()]:AddKick(
                targetIdentifier,
                targetName,
                reason,
                adminIdentifier,
                targetIP
            )
            
            -- Kick the player
            DropPlayer(playerId, "Server restart in progress.\nReason: " .. reason)
            kickedCount = kickedCount + 1
        end
    end
    
    -- Log the mass kick action
    exports[GetCurrentResourceName()]:AddLog(
        "kick",
        "Mass kick",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Reason: " .. reason .. " | Players kicked: " .. kickedCount,
        GetPlayerEndpoint(source)
    )
    
    return true, "Kicked " .. kickedCount .. " players successfully"
end

-- Kick players by IP
function kickSystem.KickPlayersByIP(source, ip, reason)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local players = GetPlayers()
    local kickedCount = 0
    
    for _, playerId in ipairs(players) do
        if GetPlayerEndpoint(playerId) == ip then
            local targetIdentifier = GetPlayerIdentifier(playerId)
            local targetName = GetPlayerName(playerId)
            
            -- Add kick to database
            exports[GetCurrentResourceName()]:AddKick(
                targetIdentifier,
                targetName,
                reason,
                adminIdentifier,
                ip
            )
            
            -- Kick the player
            DropPlayer(playerId, "You have been kicked from the server.\nReason: " .. reason)
            kickedCount = kickedCount + 1
        end
    end
    
    -- Log the IP kick action
    exports[GetCurrentResourceName()]:AddLog(
        "kick",
        "IP kick",
        ip,
        "IP Kick",
        adminIdentifier,
        adminName,
        "Reason: " .. reason .. " | Players kicked: " .. kickedCount,
        GetPlayerEndpoint(source)
    )
    
    return true, "Kicked " .. kickedCount .. " players with IP " .. ip
end

-- Get all kicks
function kickSystem.GetAllKicks()
    return exports[GetCurrentResourceName()]:GetAllKicks()
end

-- Get kick statistics
function kickSystem.GetKickStats()
    local kicks = exports[GetCurrentResourceName()]:GetAllKicks()
    local stats = {
        total = 0,
        today = 0,
        thisWeek = 0,
        thisMonth = 0,
        byReason = {}
    }
    
    local today = os.date('%Y-%m-%d')
    local weekAgo = os.date('%Y-%m-%d', os.time() - (7 * 24 * 60 * 60))
    local monthAgo = os.date('%Y-%m-%d', os.time() - (30 * 24 * 60 * 60))
    
    for _, kick in ipairs(kicks) do
        stats.total = stats.total + 1
        
        local kickDate = os.date('%Y-%m-%d', kick.kicked_at)
        if kickDate == today then
            stats.today = stats.today + 1
        end
        if kickDate >= weekAgo then
            stats.thisWeek = stats.thisWeek + 1
        end
        if kickDate >= monthAgo then
            stats.thisMonth = stats.thisMonth + 1
        end
        
        -- Count by reason
        if stats.byReason[kick.reason] then
            stats.byReason[kick.reason] = stats.byReason[kick.reason] + 1
        else
            stats.byReason[kick.reason] = 1
        end
    end
    
    return stats
end

-- Get kicks by player
function kickSystem.GetKicksByPlayer(identifier)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_kicks WHERE identifier = @identifier ORDER BY kicked_at DESC', {
        ['@identifier'] = identifier
    })
    return result
end

-- Get kicks by admin
function kickSystem.GetKicksByAdmin(adminIdentifier)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_kicks WHERE kicked_by = @admin_identifier ORDER BY kicked_at DESC', {
        ['@admin_identifier'] = adminIdentifier
    })
    return result
end

-- Get recent kicks
function kickSystem.GetRecentKicks(limit)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_kicks ORDER BY kicked_at DESC LIMIT @limit', {
        ['@limit'] = limit or 10
    })
    return result
end

-- Export functions
exports('KickPlayer', kickSystem.KickPlayer)
exports('KickAllPlayers', kickSystem.KickAllPlayers)
exports('KickPlayersByIP', kickSystem.KickPlayersByIP)
exports('GetAllKicks', kickSystem.GetAllKicks)
exports('GetKickStats', kickSystem.GetKickStats)
exports('GetKicksByPlayer', kickSystem.GetKicksByPlayer)
exports('GetKicksByAdmin', kickSystem.GetKicksByAdmin)
exports('GetRecentKicks', kickSystem.GetRecentKicks)