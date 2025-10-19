-- Database Management System for Nora Panel
local MySQL = require('mysql-async')

-- Initialize database connection
MySQL.ready(function()
    print("^2[Nora Panel]^7 Database connection established successfully!")
    CreateTables()
end)

-- Create all necessary tables
function CreateTables()
    -- Players table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(50) UNIQUE NOT NULL,
            name VARCHAR(100) NOT NULL,
            steam_id VARCHAR(20),
            license VARCHAR(50),
            discord VARCHAR(20),
            xbl VARCHAR(20),
            live VARCHAR(20),
            fivem VARCHAR(20),
            ip VARCHAR(45),
            last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            playtime INT DEFAULT 0,
            admin_level INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    -- Bans table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(50) NOT NULL,
            name VARCHAR(100) NOT NULL,
            reason TEXT NOT NULL,
            banned_by VARCHAR(50) NOT NULL,
            banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NULL,
            permanent BOOLEAN DEFAULT FALSE,
            active BOOLEAN DEFAULT TRUE,
            ip VARCHAR(45),
            steam_id VARCHAR(20),
            license VARCHAR(50),
            discord VARCHAR(20)
        )
    ]])
    
    -- Kicks table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_kicks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(50) NOT NULL,
            name VARCHAR(100) NOT NULL,
            reason TEXT NOT NULL,
            kicked_by VARCHAR(50) NOT NULL,
            kicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            ip VARCHAR(45)
        )
    ]])
    
    -- Logs table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type VARCHAR(50) NOT NULL,
            action VARCHAR(100) NOT NULL,
            player_identifier VARCHAR(50),
            player_name VARCHAR(100),
            admin_identifier VARCHAR(50),
            admin_name VARCHAR(100),
            details TEXT,
            ip VARCHAR(45),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Admin sessions table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_admin_sessions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(50) NOT NULL,
            token VARCHAR(255) UNIQUE NOT NULL,
            ip VARCHAR(45) NOT NULL,
            user_agent TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NOT NULL,
            active BOOLEAN DEFAULT TRUE
        )
    ]])
    
    -- Server stats table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_server_stats (
            id INT AUTO_INCREMENT PRIMARY KEY,
            players_online INT DEFAULT 0,
            total_players INT DEFAULT 0,
            server_fps FLOAT DEFAULT 0,
            server_ping INT DEFAULT 0,
            memory_usage FLOAT DEFAULT 0,
            cpu_usage FLOAT DEFAULT 0,
            uptime INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Announcements table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_announcements (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(200) NOT NULL,
            message TEXT NOT NULL,
            type VARCHAR(20) DEFAULT 'info',
            target VARCHAR(20) DEFAULT 'all',
            created_by VARCHAR(50) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NULL,
            active BOOLEAN DEFAULT TRUE
        )
    ]])
    
    -- Backup logs table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_backup_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            backup_name VARCHAR(100) NOT NULL,
            backup_path VARCHAR(255) NOT NULL,
            backup_size BIGINT DEFAULT 0,
            created_by VARCHAR(50) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(20) DEFAULT 'completed'
        )
    ]])
    
    -- Security events table
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS nora_security_events (
            id INT AUTO_INCREMENT PRIMARY KEY,
            event_type VARCHAR(50) NOT NULL,
            player_identifier VARCHAR(50),
            player_name VARCHAR(100),
            ip VARCHAR(45),
            details TEXT,
            severity VARCHAR(20) DEFAULT 'medium',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            resolved BOOLEAN DEFAULT FALSE
        )
    ]])
    
    print("^2[Nora Panel]^7 Database tables created successfully!")
end

-- Player Management Functions
function GetPlayerData(identifier)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_players WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    
    if result[1] then
        return result[1]
    end
    
    return nil
end

function CreatePlayerData(identifier, name, steamId, license, discord, xbl, live, fivem, ip)
    MySQL.Async.execute('INSERT INTO nora_players (identifier, name, steam_id, license, discord, xbl, live, fivem, ip) VALUES (@identifier, @name, @steam_id, @license, @discord, @xbl, @live, @fivem, @ip)', {
        ['@identifier'] = identifier,
        ['@name'] = name,
        ['@steam_id'] = steamId,
        ['@license'] = license,
        ['@discord'] = discord,
        ['@xbl'] = xbl,
        ['@live'] = live,
        ['@fivem'] = fivem,
        ['@ip'] = ip
    })
end

function UpdatePlayerData(identifier, data)
    local setClause = {}
    local values = {}
    
    for key, value in pairs(data) do
        table.insert(setClause, key .. ' = @' .. key)
        values['@' .. key] = value
    end
    
    values['@identifier'] = identifier
    
    MySQL.Async.execute('UPDATE nora_players SET ' .. table.concat(setClause, ', ') .. ' WHERE identifier = @identifier', values)
end

function GetAllPlayers()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_players ORDER BY last_seen DESC')
    return result
end

function GetOnlinePlayers()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_players WHERE last_seen > DATE_SUB(NOW(), INTERVAL 5 MINUTE) ORDER BY last_seen DESC')
    return result
end

-- Ban Management Functions
function AddBan(identifier, name, reason, bannedBy, expiresAt, permanent, ip, steamId, license, discord)
    MySQL.Async.execute('INSERT INTO nora_bans (identifier, name, reason, banned_by, expires_at, permanent, ip, steam_id, license, discord) VALUES (@identifier, @name, @reason, @banned_by, @expires_at, @permanent, @ip, @steam_id, @license, @discord)', {
        ['@identifier'] = identifier,
        ['@name'] = name,
        ['@reason'] = reason,
        ['@banned_by'] = bannedBy,
        ['@expires_at'] = expiresAt,
        ['@permanent'] = permanent,
        ['@ip'] = ip,
        ['@steam_id'] = steamId,
        ['@license'] = license,
        ['@discord'] = discord
    })
end

function GetBan(identifier)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_bans WHERE (identifier = @identifier OR ip = @identifier OR steam_id = @identifier OR license = @identifier OR discord = @identifier) AND active = 1 AND (expires_at IS NULL OR expires_at > NOW())', {
        ['@identifier'] = identifier
    })
    
    if result[1] then
        return result[1]
    end
    
    return nil
end

function GetAllBans()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_bans ORDER BY banned_at DESC')
    return result
end

function RemoveBan(banId)
    MySQL.Async.execute('UPDATE nora_bans SET active = 0 WHERE id = @id', {
        ['@id'] = banId
    })
end

-- Kick Management Functions
function AddKick(identifier, name, reason, kickedBy, ip)
    MySQL.Async.execute('INSERT INTO nora_kicks (identifier, name, reason, kicked_by, ip) VALUES (@identifier, @name, @reason, @kicked_by, @ip)', {
        ['@identifier'] = identifier,
        ['@name'] = name,
        ['@reason'] = reason,
        ['@kicked_by'] = kickedBy,
        ['@ip'] = ip
    })
end

function GetAllKicks()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_kicks ORDER BY kicked_at DESC')
    return result
end

-- Logging Functions
function AddLog(type, action, playerIdentifier, playerName, adminIdentifier, adminName, details, ip)
    MySQL.Async.execute('INSERT INTO nora_logs (type, action, player_identifier, player_name, admin_identifier, admin_name, details, ip) VALUES (@type, @action, @player_identifier, @player_name, @admin_identifier, @admin_name, @details, @ip)', {
        ['@type'] = type,
        ['@action'] = action,
        ['@player_identifier'] = playerIdentifier,
        ['@player_name'] = playerName,
        ['@admin_identifier'] = adminIdentifier,
        ['@admin_name'] = adminName,
        ['@details'] = details,
        ['@ip'] = ip
    })
end

function GetLogs(limit, offset)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_logs ORDER BY created_at DESC LIMIT @limit OFFSET @offset', {
        ['@limit'] = limit or 100,
        ['@offset'] = offset or 0
    })
    return result
end

function GetLogsByType(type, limit, offset)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_logs WHERE type = @type ORDER BY created_at DESC LIMIT @limit OFFSET @offset', {
        ['@type'] = type,
        ['@limit'] = limit or 100,
        ['@offset'] = offset or 0
    })
    return result
end

-- Admin Session Functions
function CreateAdminSession(identifier, token, ip, userAgent, expiresAt)
    MySQL.Async.execute('INSERT INTO nora_admin_sessions (identifier, token, ip, user_agent, expires_at) VALUES (@identifier, @token, @ip, @user_agent, @expires_at)', {
        ['@identifier'] = identifier,
        ['@token'] = token,
        ['@ip'] = ip,
        ['@user_agent'] = userAgent,
        ['@expires_at'] = expiresAt
    })
end

function ValidateAdminSession(token, ip)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_admin_sessions WHERE token = @token AND ip = @ip AND active = 1 AND expires_at > NOW()', {
        ['@token'] = token,
        ['@ip'] = ip
    })
    
    if result[1] then
        return result[1]
    end
    
    return nil
end

function InvalidateAdminSession(token)
    MySQL.Async.execute('UPDATE nora_admin_sessions SET active = 0 WHERE token = @token', {
        ['@token'] = token
    })
end

-- Server Stats Functions
function UpdateServerStats(playersOnline, totalPlayers, serverFps, serverPing, memoryUsage, cpuUsage, uptime)
    MySQL.Async.execute('INSERT INTO nora_server_stats (players_online, total_players, server_fps, server_ping, memory_usage, cpu_usage, uptime) VALUES (@players_online, @total_players, @server_fps, @server_ping, @memory_usage, @cpu_usage, @uptime)', {
        ['@players_online'] = playersOnline,
        ['@total_players'] = totalPlayers,
        ['@server_fps'] = serverFps,
        ['@server_ping'] = serverPing,
        ['@memory_usage'] = memoryUsage,
        ['@cpu_usage'] = cpuUsage,
        ['@uptime'] = uptime
    })
end

function GetServerStats(limit)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_server_stats ORDER BY created_at DESC LIMIT @limit', {
        ['@limit'] = limit or 100
    })
    return result
end

-- Announcement Functions
function AddAnnouncement(title, message, type, target, createdBy, expiresAt)
    MySQL.Async.execute('INSERT INTO nora_announcements (title, message, type, target, created_by, expires_at) VALUES (@title, @message, @type, @target, @created_by, @expires_at)', {
        ['@title'] = title,
        ['@message'] = message,
        ['@type'] = type,
        ['@target'] = target,
        ['@created_by'] = createdBy,
        ['@expires_at'] = expiresAt
    })
end

function GetActiveAnnouncements()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_announcements WHERE active = 1 AND (expires_at IS NULL OR expires_at > NOW()) ORDER BY created_at DESC')
    return result
end

function GetAllAnnouncements()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_announcements ORDER BY created_at DESC')
    return result
end

-- Backup Functions
function AddBackupLog(backupName, backupPath, backupSize, createdBy, status)
    MySQL.Async.execute('INSERT INTO nora_backup_logs (backup_name, backup_path, backup_size, created_by, status) VALUES (@backup_name, @backup_path, @backup_size, @created_by, @status)', {
        ['@backup_name'] = backupName,
        ['@backup_path'] = backupPath,
        ['@backup_size'] = backupSize,
        ['@created_by'] = createdBy,
        ['@status'] = status
    })
end

function GetBackupLogs()
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_backup_logs ORDER BY created_at DESC')
    return result
end

-- Security Functions
function AddSecurityEvent(eventType, playerIdentifier, playerName, ip, details, severity)
    MySQL.Async.execute('INSERT INTO nora_security_events (event_type, player_identifier, player_name, ip, details, severity) VALUES (@event_type, @player_identifier, @player_name, @ip, @details, @severity)', {
        ['@event_type'] = eventType,
        ['@player_identifier'] = playerIdentifier,
        ['@player_name'] = playerName,
        ['@ip'] = ip,
        ['@details'] = details,
        ['@severity'] = severity
    })
end

function GetSecurityEvents(limit)
    local result = MySQL.Sync.fetchAll('SELECT * FROM nora_security_events ORDER BY created_at DESC LIMIT @limit', {
        ['@limit'] = limit or 100
    })
    return result
end

function ResolveSecurityEvent(eventId)
    MySQL.Async.execute('UPDATE nora_security_events SET resolved = 1 WHERE id = @id', {
        ['@id'] = eventId
    })
end

-- Export functions
exports('GetPlayerData', GetPlayerData)
exports('CreatePlayerData', CreatePlayerData)
exports('UpdatePlayerData', UpdatePlayerData)
exports('GetAllPlayers', GetAllPlayers)
exports('GetOnlinePlayers', GetOnlinePlayers)
exports('AddBan', AddBan)
exports('GetBan', GetBan)
exports('GetAllBans', GetAllBans)
exports('RemoveBan', RemoveBan)
exports('AddKick', AddKick)
exports('GetAllKicks', GetAllKicks)
exports('AddLog', AddLog)
exports('GetLogs', GetLogs)
exports('GetLogsByType', GetLogsByType)
exports('CreateAdminSession', CreateAdminSession)
exports('ValidateAdminSession', ValidateAdminSession)
exports('InvalidateAdminSession', InvalidateAdminSession)
exports('UpdateServerStats', UpdateServerStats)
exports('GetServerStats', GetServerStats)
exports('AddAnnouncement', AddAnnouncement)
exports('GetActiveAnnouncements', GetActiveAnnouncements)
exports('GetAllAnnouncements', GetAllAnnouncements)
exports('AddBackupLog', AddBackupLog)
exports('GetBackupLogs', GetBackupLogs)
exports('AddSecurityEvent', AddSecurityEvent)
exports('GetSecurityEvents', GetSecurityEvents)
exports('ResolveSecurityEvent', ResolveSecurityEvent)