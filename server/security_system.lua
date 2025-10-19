-- Advanced Security System for Nora Panel
local securitySystem = {}

-- Security events
local securityEvents = {
    suspicious_behavior = {},
    multiple_connections = {},
    invalid_commands = {},
    resource_tampering = {},
    admin_impersonation = {}
}

-- Start security monitoring
function securitySystem.StartMonitoring()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000) -- Check every second
            
            -- Monitor for suspicious behavior
            securitySystem.MonitorSuspiciousBehavior()
            
            -- Monitor for multiple connections
            securitySystem.MonitorMultipleConnections()
            
            -- Monitor for resource tampering
            securitySystem.MonitorResourceTampering()
            
            -- Clean old security events
            securitySystem.CleanOldEvents()
        end
    end)
end

-- Monitor suspicious behavior
function securitySystem.MonitorSuspiciousBehavior()
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        local player = GetPlayerPed(playerId)
        if player then
            local coords = GetEntityCoords(player)
            local health = GetEntityHealth(player)
            local armor = GetPedArmour(player)
            
            -- Check for impossible health/armor values
            if health > 200 or health < 0 then
                securitySystem.LogSecurityEvent(
                    "suspicious_health",
                    playerId,
                    "Player has impossible health value: " .. health,
                    "high"
                )
            end
            
            if armor > 100 or armor < 0 then
                securitySystem.LogSecurityEvent(
                    "suspicious_armor",
                    playerId,
                    "Player has impossible armor value: " .. armor,
                    "high"
                )
            end
            
            -- Check for teleporting (rapid position changes)
            local playerIdentifier = GetPlayerIdentifier(playerId)
            if securityEvents.suspicious_behavior[playerIdentifier] then
                local lastCoords = securityEvents.suspicious_behavior[playerIdentifier].coords
                local distance = #(coords - lastCoords)
                local timeDiff = GetGameTimer() - securityEvents.suspicious_behavior[playerIdentifier].time
                
                if distance > 100 and timeDiff < 1000 then -- Teleported more than 100 units in less than 1 second
                    securitySystem.LogSecurityEvent(
                        "suspicious_teleport",
                        playerId,
                        "Player teleported " .. distance .. " units in " .. timeDiff .. "ms",
                        "medium"
                    )
                end
            end
            
            securityEvents.suspicious_behavior[playerIdentifier] = {
                coords = coords,
                time = GetGameTimer()
            }
        end
    end
end

-- Monitor multiple connections
function securitySystem.MonitorMultipleConnections()
    local players = GetPlayers()
    local ipCounts = {}
    
    for _, playerId in ipairs(players) do
        local ip = GetPlayerEndpoint(playerId)
        if ip then
            ipCounts[ip] = (ipCounts[ip] or 0) + 1
        end
    end
    
    for ip, count in pairs(ipCounts) do
        if count > Config.Features.securitySystem.maxConnectionsPerIP then
            securitySystem.LogSecurityEvent(
                "multiple_connections",
                nil,
                "IP " .. ip .. " has " .. count .. " connections (max: " .. Config.Features.securitySystem.maxConnectionsPerIP .. ")",
                "high"
            )
        end
    end
end

-- Monitor resource tampering
function securitySystem.MonitorResourceTampering()
    local resources = securitySystem.GetResourceList()
    
    for _, resource in ipairs(resources) do
        local state = GetResourceState(resource)
        
        if state == "stopped" then
            securitySystem.LogSecurityEvent(
                "resource_stopped",
                nil,
                "Resource " .. resource .. " was stopped unexpectedly",
                "medium"
            )
        elseif state == "started" then
            -- Check if resource was started by unauthorized user
            -- This would require additional monitoring
        end
    end
end

-- Log security event
function securitySystem.LogSecurityEvent(eventType, playerId, details, severity)
    local playerName = playerId and GetPlayerName(playerId) or "Unknown"
    local playerIdentifier = playerId and GetPlayerIdentifier(playerId) or "Unknown"
    local playerIP = playerId and GetPlayerEndpoint(playerId) or "Unknown"
    
    -- Add to database
    exports[GetCurrentResourceName()]:AddSecurityEvent(
        eventType,
        playerIdentifier,
        playerName,
        playerIP,
        details,
        severity or "medium"
    )
    
    -- Log to console
    print("^1[Nora Panel Security]^7 " .. eventType .. ": " .. details)
    
    -- Notify admins
    local players = GetPlayers()
    for _, adminId in ipairs(players) do
        if IsPlayerAceAllowed(adminId, "nora.admin") then
            TriggerClientEvent('nora:notification', adminId, {
                type = "error",
                title = "Security Alert",
                message = eventType .. ": " .. details,
                duration = 10000
            })
        end
    end
end

-- Get resource list
function securitySystem.GetResourceList()
    local resources = {}
    local resourceCount = GetNumResources()
    
    for i = 0, resourceCount - 1 do
        local resourceName = GetResourceByFindIndex(i)
        table.insert(resources, resourceName)
    end
    
    return resources
end

-- Clean old security events
function securitySystem.CleanOldEvents()
    local currentTime = GetGameTimer()
    local maxAge = 300000 -- 5 minutes
    
    for playerIdentifier, data in pairs(securityEvents.suspicious_behavior) do
        if currentTime - data.time > maxAge then
            securityEvents.suspicious_behavior[playerIdentifier] = nil
        end
    end
end

-- Get security events
function securitySystem.GetSecurityEvents(limit)
    return exports[GetCurrentResourceName()]:GetSecurityEvents(limit or 100)
end

-- Get security statistics
function securitySystem.GetSecurityStats()
    local events = securitySystem.GetSecurityEvents(1000)
    local stats = {
        total = 0,
        byType = {},
        bySeverity = {},
        today = 0,
        thisWeek = 0,
        thisMonth = 0,
        resolved = 0,
        unresolved = 0
    }
    
    local today = os.date('%Y-%m-%d')
    local weekAgo = os.date('%Y-%m-%d', os.time() - (7 * 24 * 60 * 60))
    local monthAgo = os.date('%Y-%m-%d', os.time() - (30 * 24 * 60 * 60))
    
    for _, event in ipairs(events) do
        stats.total = stats.total + 1
        
        -- Count by type
        if stats.byType[event.event_type] then
            stats.byType[event.event_type] = stats.byType[event.event_type] + 1
        else
            stats.byType[event.event_type] = 1
        end
        
        -- Count by severity
        if stats.bySeverity[event.severity] then
            stats.bySeverity[event.severity] = stats.bySeverity[event.severity] + 1
        else
            stats.bySeverity[event.severity] = 1
        end
        
        -- Count by date
        local eventDate = os.date('%Y-%m-%d', event.created_at)
        if eventDate == today then
            stats.today = stats.today + 1
        end
        if eventDate >= weekAgo then
            stats.thisWeek = stats.thisWeek + 1
        end
        if eventDate >= monthAgo then
            stats.thisMonth = stats.thisMonth + 1
        end
        
        -- Count resolved/unresolved
        if event.resolved then
            stats.resolved = stats.resolved + 1
        else
            stats.unresolved = stats.unresolved + 1
        end
    end
    
    return stats
end

-- Resolve security event
function securitySystem.ResolveSecurityEvent(eventId)
    exports[GetCurrentResourceName()]:ResolveSecurityEvent(eventId)
    return true, "Security event resolved successfully"
end

-- Ban suspicious player
function securitySystem.BanSuspiciousPlayer(source, playerId, reason)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(playerId)
    local targetName = GetPlayerName(playerId)
    
    -- Ban the player
    local success, message = exports[GetCurrentResourceName()]:BanPlayer(source, playerId, reason, nil, true)
    
    if success then
        -- Log the security action
        securitySystem.LogSecurityEvent(
            "suspicious_player_banned",
            playerId,
            "Player banned for suspicious behavior: " .. reason,
            "high"
        )
        
        return true, "Suspicious player banned successfully"
    else
        return false, message
    end
end

-- Kick suspicious player
function securitySystem.KickSuspiciousPlayer(source, playerId, reason)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(playerId)
    local targetName = GetPlayerName(playerId)
    
    -- Kick the player
    local success, message = exports[GetCurrentResourceName()]:KickPlayer(source, playerId, reason)
    
    if success then
        -- Log the security action
        securitySystem.LogSecurityEvent(
            "suspicious_player_kicked",
            playerId,
            "Player kicked for suspicious behavior: " .. reason,
            "medium"
        )
        
        return true, "Suspicious player kicked successfully"
    else
        return false, message
    end
end

-- Get security recommendations
function securitySystem.GetSecurityRecommendations()
    local recommendations = {}
    local stats = securitySystem.GetSecurityStats()
    
    -- High severity events
    if stats.bySeverity.high and stats.bySeverity.high > 0 then
        table.insert(recommendations, {
            type = "high_severity",
            message = "High severity security events detected. Review and take action immediately.",
            action = "Check recent security events and ban/kick suspicious players"
        })
    end
    
    -- Multiple unresolved events
    if stats.unresolved > 10 then
        table.insert(recommendations, {
            type = "unresolved_events",
            message = "Many unresolved security events. Review and resolve them.",
            action = "Review security events and resolve or dismiss them"
        })
    end
    
    -- Suspicious behavior
    if stats.byType.suspicious_behavior and stats.byType.suspicious_behavior > 5 then
        table.insert(recommendations, {
            type = "suspicious_behavior",
            message = "High amount of suspicious behavior detected. Consider stricter monitoring.",
            action = "Review player behavior and consider additional security measures"
        })
    end
    
    return recommendations
end

-- Export functions
exports('StartMonitoring', securitySystem.StartMonitoring)
exports('LogSecurityEvent', securitySystem.LogSecurityEvent)
exports('GetSecurityEvents', securitySystem.GetSecurityEvents)
exports('GetSecurityStats', securitySystem.GetSecurityStats)
exports('ResolveSecurityEvent', securitySystem.ResolveSecurityEvent)
exports('BanSuspiciousPlayer', securitySystem.BanSuspiciousPlayer)
exports('KickSuspiciousPlayer', securitySystem.KickSuspiciousPlayer)
exports('GetSecurityRecommendations', securitySystem.GetSecurityRecommendations)

-- Start security monitoring when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(10000) -- Wait 10 seconds after resource start
    securitySystem.StartMonitoring()
end)