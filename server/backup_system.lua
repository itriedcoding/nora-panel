-- Advanced Backup System for Nora Panel
local backupSystem = {}

-- Create backup
function backupSystem.CreateBackup(source, backupName, includeDatabase, includeLogs, includeConfig)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    local timestamp = os.date('%Y-%m-%d_%H-%M-%S')
    local backupName = backupName or "backup_" .. timestamp
    local backupPath = "backups/" .. backupName
    
    -- Create backup directory
    os.execute("mkdir -p " .. backupPath)
    
    local backupItems = {}
    local backupSize = 0
    
    -- Backup database
    if includeDatabase then
        local dbBackupPath = backupPath .. "/database.sql"
        local dbCommand = "mysqldump -h " .. Config.Database.host .. " -u " .. Config.Database.username .. " -p" .. Config.Database.password .. " " .. Config.Database.database .. " > " .. dbBackupPath
        os.execute(dbCommand)
        
        table.insert(backupItems, {
            type = "database",
            path = dbBackupPath,
            size = backupSystem.GetFileSize(dbBackupPath)
        })
    end
    
    -- Backup logs
    if includeLogs then
        local logsPath = backupPath .. "/logs"
        os.execute("mkdir -p " .. logsPath)
        os.execute("cp -r logs/* " .. logsPath .. "/ 2>/dev/null || true")
        
        table.insert(backupItems, {
            type = "logs",
            path = logsPath,
            size = backupSystem.GetDirectorySize(logsPath)
        })
    end
    
    -- Backup config
    if includeConfig then
        local configPath = backupPath .. "/config"
        os.execute("mkdir -p " .. configPath)
        os.execute("cp -r config/* " .. configPath .. "/ 2>/dev/null || true")
        
        table.insert(backupItems, {
            type = "config",
            path = configPath,
            size = backupSystem.GetDirectorySize(configPath)
        })
    end
    
    -- Calculate total size
    for _, item in ipairs(backupItems) do
        backupSize = backupSize + item.size
    end
    
    -- Create backup info file
    local backupInfo = {
        name = backupName,
        created_at = os.date('%Y-%m-%d %H:%M:%S'),
        created_by = adminName,
        created_by_identifier = adminIdentifier,
        items = backupItems,
        total_size = backupSize,
        version = Config.PanelVersion
    }
    
    local infoFile = io.open(backupPath .. "/backup_info.json", "w")
    if infoFile then
        infoFile:write(json.encode(backupInfo, {indent = true}))
        infoFile:close()
    end
    
    -- Add to database
    exports[GetCurrentResourceName()]:AddBackupLog(
        backupName,
        backupPath,
        backupSize,
        adminIdentifier,
        "completed"
    )
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "backup",
        "Backup created",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Backup: " .. backupName .. " | Size: " .. backupSystem.FormatFileSize(backupSize),
        GetPlayerEndpoint(source)
    )
    
    return true, "Backup created successfully: " .. backupName
end

-- Restore backup
function backupSystem.RestoreBackup(source, backupName)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    local backupPath = "backups/" .. backupName
    local infoFile = backupPath .. "/backup_info.json"
    
    -- Check if backup exists
    local file = io.open(infoFile, "r")
    if not file then
        return false, "Backup not found"
    end
    
    local backupInfo = json.decode(file:read("*a"))
    file:close()
    
    -- Restore database
    if backupInfo.items then
        for _, item in ipairs(backupInfo.items) do
            if item.type == "database" then
                local dbCommand = "mysql -h " .. Config.Database.host .. " -u " .. Config.Database.username .. " -p" .. Config.Database.password .. " " .. Config.Database.database .. " < " .. item.path
                os.execute(dbCommand)
            elseif item.type == "logs" then
                os.execute("cp -r " .. item.path .. "/* logs/ 2>/dev/null || true")
            elseif item.type == "config" then
                os.execute("cp -r " .. item.path .. "/* config/ 2>/dev/null || true")
            end
        end
    end
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "backup",
        "Backup restored",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Backup: " .. backupName,
        GetPlayerEndpoint(source)
    )
    
    return true, "Backup restored successfully: " .. backupName
end

-- Delete backup
function backupSystem.DeleteBackup(source, backupName)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    local backupPath = "backups/" .. backupName
    
    -- Check if backup exists
    if not os.execute("test -d " .. backupPath) then
        return false, "Backup not found"
    end
    
    -- Delete backup directory
    os.execute("rm -rf " .. backupPath)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "backup",
        "Backup deleted",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Backup: " .. backupName,
        GetPlayerEndpoint(source)
    )
    
    return true, "Backup deleted successfully: " .. backupName
end

-- List backups
function backupSystem.ListBackups()
    local backups = {}
    local backupDir = "backups/"
    
    -- Get all backup directories
    local handle = io.popen("ls -la " .. backupDir .. " 2>/dev/null | grep '^d' | awk '{print $9}' | grep -v '^\.$' | grep -v '^\.\.$'")
    if handle then
        for backupName in handle:lines() do
            local backupPath = backupDir .. backupName
            local infoFile = backupPath .. "/backup_info.json"
            
            local file = io.open(infoFile, "r")
            if file then
                local backupInfo = json.decode(file:read("*a"))
                file:close()
                
                table.insert(backups, {
                    name = backupName,
                    path = backupPath,
                    created_at = backupInfo.created_at,
                    created_by = backupInfo.created_by,
                    total_size = backupInfo.total_size,
                    formatted_size = backupSystem.FormatFileSize(backupInfo.total_size),
                    version = backupInfo.version
                })
            end
        end
        handle:close()
    end
    
    -- Sort by creation date (newest first)
    table.sort(backups, function(a, b) return a.created_at > b.created_at end)
    
    return backups
end

-- Get backup info
function backupSystem.GetBackupInfo(backupName)
    local backupPath = "backups/" .. backupName
    local infoFile = backupPath .. "/backup_info.json"
    
    local file = io.open(infoFile, "r")
    if not file then
        return nil
    end
    
    local backupInfo = json.decode(file:read("*a"))
    file:close()
    
    return backupInfo
end

-- Get file size
function backupSystem.GetFileSize(filePath)
    local handle = io.popen("stat -c%s " .. filePath .. " 2>/dev/null")
    if handle then
        local size = handle:read("*a")
        handle:close()
        return tonumber(size) or 0
    end
    return 0
end

-- Get directory size
function backupSystem.GetDirectorySize(dirPath)
    local handle = io.popen("du -sb " .. dirPath .. " 2>/dev/null | awk '{print $1}'")
    if handle then
        local size = handle:read("*a")
        handle:close()
        return tonumber(size) or 0
    end
    return 0
end

-- Format file size
function backupSystem.FormatFileSize(bytes)
    if bytes < 1024 then
        return bytes .. " B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.2f KB", bytes / 1024)
    elseif bytes < 1024 * 1024 * 1024 then
        return string.format("%.2f MB", bytes / (1024 * 1024))
    else
        return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
    end
end

-- Clean old backups
function backupSystem.CleanOldBackups(maxBackups)
    local backups = backupSystem.ListBackups()
    local maxBackups = maxBackups or Config.Features.backupSystem.maxBackups
    
    if #backups > maxBackups then
        local backupsToDelete = {}
        for i = maxBackups + 1, #backups do
            table.insert(backupsToDelete, backups[i])
        end
        
        for _, backup in ipairs(backupsToDelete) do
            backupSystem.DeleteBackup(nil, backup.name)
        end
        
        return true, "Cleaned " .. #backupsToDelete .. " old backups"
    end
    
    return true, "No old backups to clean"
end

-- Auto backup
function backupSystem.AutoBackup()
    local timestamp = os.date('%Y-%m-%d_%H-%M-%S')
    local backupName = "auto_backup_" .. timestamp
    
    local success, message = backupSystem.CreateBackup(nil, backupName, true, true, true)
    
    if success then
        print("^2[Nora Panel]^7 Auto backup created: " .. backupName)
        
        -- Clean old backups
        backupSystem.CleanOldBackups()
    else
        print("^1[Nora Panel]^7 Auto backup failed: " .. message)
    end
    
    return success, message
end

-- Get backup statistics
function backupSystem.GetBackupStats()
    local backups = backupSystem.ListBackups()
    local totalSize = 0
    local totalBackups = #backups
    
    for _, backup in ipairs(backups) do
        totalSize = totalSize + backup.total_size
    end
    
    return {
        totalBackups = totalBackups,
        totalSize = totalSize,
        formattedSize = backupSystem.FormatFileSize(totalSize),
        averageSize = totalBackups > 0 and (totalSize / totalBackups) or 0,
        formattedAverageSize = totalBackups > 0 and backupSystem.FormatFileSize(totalSize / totalBackups) or "0 B"
    }
end

-- Export functions
exports('CreateBackup', backupSystem.CreateBackup)
exports('RestoreBackup', backupSystem.RestoreBackup)
exports('DeleteBackup', backupSystem.DeleteBackup)
exports('ListBackups', backupSystem.ListBackups)
exports('GetBackupInfo', backupSystem.GetBackupInfo)
exports('GetFileSize', backupSystem.GetFileSize)
exports('GetDirectorySize', backupSystem.GetDirectorySize)
exports('FormatFileSize', backupSystem.FormatFileSize)
exports('CleanOldBackups', backupSystem.CleanOldBackups)
exports('AutoBackup', backupSystem.AutoBackup)
exports('GetBackupStats', backupSystem.GetBackupStats)

-- Auto backup thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Features.backupSystem.backupInterval * 1000) -- Convert to milliseconds
        if Config.Features.backupSystem.autoBackup then
            backupSystem.AutoBackup()
        end
    end
end)