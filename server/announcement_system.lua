-- Advanced Announcement System for Nora Panel
local announcementSystem = {}

-- Create announcement
function announcementSystem.CreateAnnouncement(source, title, message, type, target, expiresAt)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Add announcement to database
    exports[GetCurrentResourceName()]:AddAnnouncement(
        title,
        message,
        type or "info",
        target or "all",
        adminIdentifier,
        expiresAt
    )
    
    -- Send announcement to players
    if target == "all" then
        TriggerClientEvent('nora:announcement', -1, {
            title = title,
            message = message,
            type = type or "info",
            duration = 10000
        })
    elseif target == "staff" then
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            if IsPlayerAceAllowed(playerId, "nora.admin") then
                TriggerClientEvent('nora:announcement', playerId, {
                    title = title,
                    message = message,
                    type = type or "info",
                    duration = 10000
                })
            end
        end
    else
        -- Send to specific player
        local targetId = tonumber(target)
        if targetId then
            TriggerClientEvent('nora:announcement', targetId, {
                title = title,
                message = message,
                type = type or "info",
                duration = 10000
            })
        end
    end
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "announcement",
        "Announcement created",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Title: " .. title .. " | Target: " .. (target or "all") .. " | Type: " .. (type or "info"),
        GetPlayerEndpoint(source)
    )
    
    return true, "Announcement created successfully"
end

-- Get active announcements
function announcementSystem.GetActiveAnnouncements()
    return exports[GetCurrentResourceName()]:GetActiveAnnouncements()
end

-- Get all announcements
function announcementSystem.GetAllAnnouncements()
    return exports[GetCurrentResourceName()]:GetAllAnnouncements()
end

-- Delete announcement
function announcementSystem.DeleteAnnouncement(source, announcementId)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Delete announcement from database
    MySQL.Async.execute('UPDATE nora_announcements SET active = 0 WHERE id = @id', {
        ['@id'] = announcementId
    })
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "announcement",
        "Announcement deleted",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Announcement ID: " .. announcementId,
        GetPlayerEndpoint(source)
    )
    
    return true, "Announcement deleted successfully"
end

-- Send quick announcement
function announcementSystem.SendQuickAnnouncement(source, message, type)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Send announcement to all players
    TriggerClientEvent('nora:announcement', -1, {
        title = "Server Announcement",
        message = message,
        type = type or "info",
        duration = 8000
    })
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "announcement",
        "Quick announcement sent",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Message: " .. message .. " | Type: " .. (type or "info"),
        GetPlayerEndpoint(source)
    )
    
    return true, "Quick announcement sent successfully"
end

-- Send staff announcement
function announcementSystem.SendStaffAnnouncement(source, message, type)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Send announcement to staff only
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if IsPlayerAceAllowed(playerId, "nora.admin") then
            TriggerClientEvent('nora:announcement', playerId, {
                title = "Staff Announcement",
                message = message,
                type = type or "info",
                duration = 8000
            })
        end
    end
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "announcement",
        "Staff announcement sent",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Message: " .. message .. " | Type: " .. (type or "info"),
        GetPlayerEndpoint(source)
    )
    
    return true, "Staff announcement sent successfully"
end

-- Send player announcement
function announcementSystem.SendPlayerAnnouncement(source, targetId, message, type)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Send announcement to specific player
    TriggerClientEvent('nora:announcement', targetId, {
        title = "Personal Message",
        message = message,
        type = type or "info",
        duration = 8000
    })
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "announcement",
        "Player announcement sent",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Message: " .. message .. " | Type: " .. (type or "info"),
        GetPlayerEndpoint(source)
    )
    
    return true, "Player announcement sent successfully"
end

-- Get announcement types
function announcementSystem.GetAnnouncementTypes()
    return {
        {value = "info", label = "Information", color = "#2196F3"},
        {value = "success", label = "Success", color = "#4CAF50"},
        {value = "warning", label = "Warning", color = "#FF9800"},
        {value = "error", label = "Error", color = "#F44336"},
        {value = "important", label = "Important", color = "#9C27B0"}
    }
end

-- Get announcement targets
function announcementSystem.GetAnnouncementTargets()
    return {
        {value = "all", label = "All Players"},
        {value = "staff", label = "Staff Only"},
        {value = "online", label = "Online Players Only"}
    }
end

-- Get announcement statistics
function announcementSystem.GetAnnouncementStats()
    local announcements = exports[GetCurrentResourceName()]:GetAllAnnouncements()
    local stats = {
        total = 0,
        active = 0,
        expired = 0,
        byType = {},
        byTarget = {},
        today = 0,
        thisWeek = 0,
        thisMonth = 0
    }
    
    local today = os.date('%Y-%m-%d')
    local weekAgo = os.date('%Y-%m-%d', os.time() - (7 * 24 * 60 * 60))
    local monthAgo = os.date('%Y-%m-%d', os.time() - (30 * 24 * 60 * 60))
    
    for _, announcement in ipairs(announcements) do
        stats.total = stats.total + 1
        
        if announcement.active then
            stats.active = stats.active + 1
        else
            stats.expired = stats.expired + 1
        end
        
        -- Count by type
        if stats.byType[announcement.type] then
            stats.byType[announcement.type] = stats.byType[announcement.type] + 1
        else
            stats.byType[announcement.type] = 1
        end
        
        -- Count by target
        if stats.byTarget[announcement.target] then
            stats.byTarget[announcement.target] = stats.byTarget[announcement.target] + 1
        else
            stats.byTarget[announcement.target] = 1
        end
        
        local announcementDate = os.date('%Y-%m-%d', announcement.created_at)
        if announcementDate == today then
            stats.today = stats.today + 1
        end
        if announcementDate >= weekAgo then
            stats.thisWeek = stats.thisWeek + 1
        end
        if announcementDate >= monthAgo then
            stats.thisMonth = stats.thisMonth + 1
        end
    end
    
    return stats
end

-- Clean expired announcements
function announcementSystem.CleanExpiredAnnouncements()
    MySQL.Async.execute('UPDATE nora_announcements SET active = 0 WHERE expires_at IS NOT NULL AND expires_at < NOW() AND active = 1', {})
    print("^2[Nora Panel]^7 Expired announcements cleaned up")
end

-- Export functions
exports('CreateAnnouncement', announcementSystem.CreateAnnouncement)
exports('GetActiveAnnouncements', announcementSystem.GetActiveAnnouncements)
exports('GetAllAnnouncements', announcementSystem.GetAllAnnouncements)
exports('DeleteAnnouncement', announcementSystem.DeleteAnnouncement)
exports('SendQuickAnnouncement', announcementSystem.SendQuickAnnouncement)
exports('SendStaffAnnouncement', announcementSystem.SendStaffAnnouncement)
exports('SendPlayerAnnouncement', announcementSystem.SendPlayerAnnouncement)
exports('GetAnnouncementTypes', announcementSystem.GetAnnouncementTypes)
exports('GetAnnouncementTargets', announcementSystem.GetAnnouncementTargets)
exports('GetAnnouncementStats', announcementSystem.GetAnnouncementStats)
exports('CleanExpiredAnnouncements', announcementSystem.CleanExpiredAnnouncements)

-- Clean expired announcements every hour
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- 1 hour
        announcementSystem.CleanExpiredAnnouncements()
    end
end)