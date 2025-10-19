-- Advanced Logging System for Nora Panel
local logger = {}

-- Log levels
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
    CRITICAL = 5
}

-- Current log level
local currentLogLevel = LOG_LEVELS.INFO

-- Set log level
function logger.SetLogLevel(level)
    currentLogLevel = LOG_LEVELS[level] or LOG_LEVELS.INFO
end

-- Get log level
function logger.GetLogLevel()
    for level, value in pairs(LOG_LEVELS) do
        if value == currentLogLevel then
            return level
        end
    end
    return "INFO"
end

-- Log message
function logger.Log(level, message, data)
    local logLevel = LOG_LEVELS[level] or LOG_LEVELS.INFO
    
    if logLevel >= currentLogLevel then
        local timestamp = os.date('%Y-%m-%d %H:%M:%S')
        local logMessage = string.format("[%s] [%s] %s", timestamp, level, message)
        
        if data then
            logMessage = logMessage .. " | Data: " .. json.encode(data)
        end
        
        print(logMessage)
        
        -- Save to file
        logger.SaveToFile(logMessage)
    end
end

-- Debug log
function logger.Debug(message, data)
    logger.Log("DEBUG", message, data)
end

-- Info log
function logger.Info(message, data)
    logger.Log("INFO", message, data)
end

-- Warning log
function logger.Warning(message, data)
    logger.Log("WARNING", message, data)
end

-- Error log
function logger.Error(message, data)
    logger.Log("ERROR", message, data)
end

-- Critical log
function logger.Critical(message, data)
    logger.Log("CRITICAL", message, data)
end

-- Save log to file
function logger.SaveToFile(message)
    local logFile = "nora_panel.log"
    local file = io.open(logFile, "a")
    if file then
        file:write(message .. "\n")
        file:close()
    end
end

-- Get log file content
function logger.GetLogFileContent(lines)
    local logFile = "nora_panel.log"
    local file = io.open(logFile, "r")
    if not file then
        return {}
    end
    
    local content = {}
    local count = 0
    
    for line in file:lines() do
        table.insert(content, 1, line) -- Insert at beginning to reverse order
        count = count + 1
        if lines and count >= lines then
            break
        end
    end
    
    file:close()
    return content
end

-- Clear log file
function logger.ClearLogFile()
    local logFile = "nora_panel.log"
    local file = io.open(logFile, "w")
    if file then
        file:write("")
        file:close()
        return true
    end
    return false
end

-- Get log statistics
function logger.GetLogStats()
    local logFile = "nora_panel.log"
    local file = io.open(logFile, "r")
    if not file then
        return {
            totalLines = 0,
            fileSize = 0,
            byLevel = {}
        }
    end
    
    local stats = {
        totalLines = 0,
        fileSize = 0,
        byLevel = {}
    }
    
    for line in file:lines() do
        stats.totalLines = stats.totalLines + 1
        
        -- Count by level
        for level, _ in pairs(LOG_LEVELS) do
            if string.find(line, "%[" .. level .. "%]") then
                stats.byLevel[level] = (stats.byLevel[level] or 0) + 1
                break
            end
        end
    end
    
    file:close()
    
    -- Get file size
    local fileInfo = io.popen("stat -c%s " .. logFile)
    if fileInfo then
        local size = fileInfo:read("*a")
        stats.fileSize = tonumber(size) or 0
        fileInfo:close()
    end
    
    return stats
end

-- Log player action
function logger.LogPlayerAction(playerId, action, details)
    local playerName = GetPlayerName(playerId)
    local playerIdentifier = GetPlayerIdentifier(playerId)
    local playerIP = GetPlayerEndpoint(playerId)
    
    logger.Info("Player Action", {
        player = playerName,
        identifier = playerIdentifier,
        action = action,
        details = details,
        ip = playerIP
    })
    
    -- Also save to database
    exports[GetCurrentResourceName()]:AddLog(
        "player_action",
        action,
        playerIdentifier,
        playerName,
        nil,
        nil,
        details,
        playerIP
    )
end

-- Log admin action
function logger.LogAdminAction(adminId, targetId, action, details)
    local adminName = GetPlayerName(adminId)
    local adminIdentifier = GetPlayerIdentifier(adminId)
    local adminIP = GetPlayerEndpoint(adminId)
    
    local targetName = targetId and GetPlayerName(targetId) or "N/A"
    local targetIdentifier = targetId and GetPlayerIdentifier(targetId) or "N/A"
    
    logger.Info("Admin Action", {
        admin = adminName,
        adminIdentifier = adminIdentifier,
        target = targetName,
        targetIdentifier = targetIdentifier,
        action = action,
        details = details,
        ip = adminIP
    })
    
    -- Also save to database
    exports[GetCurrentResourceName()]:AddLog(
        "admin_action",
        action,
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        details,
        adminIP
    )
end

-- Log server event
function logger.LogServerEvent(event, details)
    logger.Info("Server Event", {
        event = event,
        details = details
    })
    
    -- Also save to database
    exports[GetCurrentResourceName()]:AddLog(
        "server_event",
        event,
        nil,
        nil,
        nil,
        nil,
        details,
        "127.0.0.1"
    )
end

-- Log security event
function logger.LogSecurityEvent(event, playerId, details, severity)
    local playerName = playerId and GetPlayerName(playerId) or "Unknown"
    local playerIdentifier = playerId and GetPlayerIdentifier(playerId) or "Unknown"
    local playerIP = playerId and GetPlayerEndpoint(playerId) or "Unknown"
    
    logger.Warning("Security Event", {
        event = event,
        player = playerName,
        identifier = playerIdentifier,
        details = details,
        severity = severity,
        ip = playerIP
    })
    
    -- Also save to database
    exports[GetCurrentResourceName()]:AddSecurityEvent(
        event,
        playerIdentifier,
        playerName,
        playerIP,
        details,
        severity or "medium"
    )
end

-- Log error
function logger.LogError(error, details)
    logger.Error("Error", {
        error = error,
        details = details
    })
    
    -- Also save to database
    exports[GetCurrentResourceName()]:AddLog(
        "error",
        "Error occurred",
        nil,
        nil,
        nil,
        nil,
        "Error: " .. error .. " | Details: " .. (details or "N/A"),
        "127.0.0.1"
    )
end

-- Get recent logs
function logger.GetRecentLogs(limit, level)
    local logs = exports[GetCurrentResourceName()]:GetLogs(limit or 100, 0)
    
    if level then
        local filteredLogs = {}
        for _, log in ipairs(logs) do
            if log.type == level then
                table.insert(filteredLogs, log)
            end
        end
        return filteredLogs
    end
    
    return logs
end

-- Search logs
function logger.SearchLogs(query, limit, offset)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_logs WHERE action LIKE @query OR details LIKE @query OR player_name LIKE @query OR admin_name LIKE @query ORDER BY created_at DESC LIMIT @limit OFFSET @offset', {
        ['@query'] = '%' .. query .. '%',
        ['@limit'] = limit or 100,
        ['@offset'] = offset or 0
    })
    return result
end

-- Export functions
exports('SetLogLevel', logger.SetLogLevel)
exports('GetLogLevel', logger.GetLogLevel)
exports('Log', logger.Log)
exports('Debug', logger.Debug)
exports('Info', logger.Info)
exports('Warning', logger.Warning)
exports('Error', logger.Error)
exports('Critical', logger.Critical)
exports('SaveToFile', logger.SaveToFile)
exports('GetLogFileContent', logger.GetLogFileContent)
exports('ClearLogFile', logger.ClearLogFile)
exports('GetLogStats', logger.GetLogStats)
exports('LogPlayerAction', logger.LogPlayerAction)
exports('LogAdminAction', logger.LogAdminAction)
exports('LogServerEvent', logger.LogServerEvent)
exports('LogSecurityEvent', logger.LogSecurityEvent)
exports('LogError', logger.LogError)
exports('GetRecentLogs', logger.GetRecentLogs)
exports('SearchLogs', logger.SearchLogs)