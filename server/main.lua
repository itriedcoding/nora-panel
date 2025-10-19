-- Main Server Script for Nora Panel
local noraPanel = {}

-- Initialize the panel
function noraPanel.Initialize()
    print("^2[Nora Panel]^7 Initializing...")
    
    -- Initialize database
    noraPanel.InitializeDatabase()
    
    -- Initialize systems
    noraPanel.InitializeSystems()
    
    -- Start monitoring
    noraPanel.StartMonitoring()
    
    print("^2[Nora Panel]^7 Initialized successfully!")
end

-- Initialize database
function noraPanel.InitializeDatabase()
    print("^2[Nora Panel]^7 Database initialized")
end

-- Initialize systems
function noraPanel.InitializeSystems()
    -- Start performance monitoring
    if Config.Features.performanceMonitor.enabled then
        exports[GetCurrentResourceName()]:StartMonitoring()
    end
    
    -- Start security monitoring
    if Config.Features.securitySystem.enabled then
        exports[GetCurrentResourceName()]:StartMonitoring()
    end
    
    print("^2[Nora Panel]^7 Systems initialized")
end

-- Start monitoring
function noraPanel.StartMonitoring()
    -- Monitor player connections
    AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
        local source = source
        local playerName = name
        local playerIdentifier = GetPlayerIdentifier(source)
        local playerIP = GetPlayerEndpoint(source)
        
        -- Log connection
        exports[GetCurrentResourceName()]:AddLog(
            "connection",
            "Player connecting",
            playerIdentifier,
            playerName,
            nil,
            nil,
            "IP: " .. playerIP,
            playerIP
        )
        
        -- Check for bans
        local ban = exports[GetCurrentResourceName()]:GetBan(playerIdentifier)
        if ban then
            setKickReason("You are banned from this server.\nReason: " .. ban.reason .. (ban.expires_at and "\nExpires: " .. ban.expires_at or "\nPermanent ban"))
            CancelEvent()
            return
        end
        
        -- Check IP ban
        local ipBan = exports[GetCurrentResourceName()]:GetBan(playerIP)
        if ipBan then
            setKickReason("Your IP is banned from this server.\nReason: " .. ipBan.reason)
            CancelEvent()
            return
        end
    end)
    
    -- Monitor player disconnections
    AddEventHandler('playerDropped', function(reason)
        local source = source
        local playerName = GetPlayerName(source)
        local playerIdentifier = GetPlayerIdentifier(source)
        local playerIP = GetPlayerEndpoint(source)
        
        -- Log disconnection
        exports[GetCurrentResourceName()]:AddLog(
            "connection",
            "Player disconnected",
            playerIdentifier,
            playerName,
            nil,
            nil,
            "Reason: " .. reason .. " | IP: " .. playerIP,
            playerIP
        )
        
        -- Update player data
        if playerIdentifier then
            exports[GetCurrentResourceName()]:UpdatePlayerData(playerIdentifier, {
                last_seen = os.date('%Y-%m-%d %H:%M:%S')
            })
        end
    end)
    
    -- Monitor player deaths
    AddEventHandler('baseevents:onPlayerDied', function(killerType, coords)
        local source = source
        local playerName = GetPlayerName(source)
        local playerIdentifier = GetPlayerIdentifier(source)
        
        -- Log death
        exports[GetCurrentResourceName()]:AddLog(
            "death",
            "Player died",
            playerIdentifier,
            playerName,
            nil,
            nil,
            "Killer Type: " .. killerType .. " | Coords: " .. json.encode(coords),
            GetPlayerEndpoint(source)
        )
    end)
    
    -- Monitor player kills
    AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
        local source = source
        local killerName = GetPlayerName(killerId)
        local killerIdentifier = GetPlayerIdentifier(killerId)
        local victimName = GetPlayerName(source)
        local victimIdentifier = GetPlayerIdentifier(source)
        
        -- Log kill
        exports[GetCurrentResourceName()]:AddLog(
            "kill",
            "Player killed",
            victimIdentifier,
            victimName,
            killerIdentifier,
            killerName,
            "Death Data: " .. json.encode(deathData),
            GetPlayerEndpoint(source)
        )
    end)
    
    print("^2[Nora Panel]^7 Monitoring started")
end

-- Register commands
RegisterCommand('nora', function(source, args, rawCommand)
    if source == 0 then
        print("^1[Nora Panel]^7 This command can only be used by players")
        return
    end
    
    if not IsPlayerAceAllowed(source, "nora.admin") then
        TriggerClientEvent('nora:notification', source, {
            type = "error",
            title = "Access Denied",
            message = "You don't have permission to use this command",
            duration = 5000
        })
        return
    end
    
    local subCommand = args[1]
    
    if subCommand == "panel" then
        TriggerClientEvent('nora:openPanel', source)
    elseif subCommand == "ban" then
        local targetId = tonumber(args[2])
        local reason = table.concat(args, " ", 3)
        
        if not targetId or not reason then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora ban <player_id> <reason>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:BanPlayer(source, targetId, reason, nil, true)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Banned" or "Ban Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "kick" then
        local targetId = tonumber(args[2])
        local reason = table.concat(args, " ", 3)
        
        if not targetId or not reason then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora kick <player_id> <reason>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:KickPlayer(source, targetId, reason)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Kicked" or "Kick Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "heal" then
        local targetId = tonumber(args[2])
        
        if not targetId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora heal <player_id>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:HealPlayer(source, targetId)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Healed" or "Heal Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "revive" then
        local targetId = tonumber(args[2])
        
        if not targetId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora revive <player_id>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:RevivePlayer(source, targetId)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Revived" or "Revive Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "freeze" then
        local targetId = tonumber(args[2])
        local freeze = args[3] == "true"
        
        if not targetId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora freeze <player_id> <true/false>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:FreezePlayer(source, targetId, freeze)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and (freeze and "Player Frozen" or "Player Unfrozen") or "Freeze Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "tp" then
        local targetId = tonumber(args[2])
        local destinationId = tonumber(args[3])
        
        if not targetId or not destinationId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora tp <player_id> <destination_id>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:TeleportToPlayer(source, targetId, destinationId)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Teleported" or "Teleport Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "bring" then
        local targetId = tonumber(args[2])
        
        if not targetId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora bring <player_id>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:BringPlayer(source, targetId)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Player Brought" or "Bring Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "goto" then
        local targetId = tonumber(args[2])
        
        if not targetId then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora goto <player_id>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:GoToPlayer(source, targetId)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Teleported to Player" or "Teleport Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "weather" then
        local weatherType = args[2]
        
        if not weatherType then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora weather <weather_type>",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:SetWeather(source, weatherType)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Weather Changed" or "Weather Change Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "time" then
        local hour = tonumber(args[2])
        local minute = tonumber(args[3]) or 0
        local second = tonumber(args[4]) or 0
        
        if not hour then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora time <hour> [minute] [second]",
                duration = 5000
            })
            return
        end
        
        local success, message = exports[GetCurrentResourceName()]:SetTime(source, hour, minute, second)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Time Changed" or "Time Change Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "announce" then
        local message = table.concat(args, " ", 2)
        
        if not message then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora announce <message>",
                duration = 5000
            })
            return
        end
        
        local success, msg = exports[GetCurrentResourceName()]:SendQuickAnnouncement(source, message)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Announcement Sent" or "Announcement Failed",
            message = msg,
            duration = 5000
        })
    elseif subCommand == "staff" then
        local message = table.concat(args, " ", 2)
        
        if not message then
            TriggerClientEvent('nora:notification', source, {
                type = "error",
                title = "Invalid Usage",
                message = "Usage: /nora staff <message>",
                duration = 5000
            })
            return
        end
        
        local success, msg = exports[GetCurrentResourceName()]:SendStaffAnnouncement(source, message)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Staff Announcement Sent" or "Staff Announcement Failed",
            message = msg,
            duration = 5000
        })
    elseif subCommand == "backup" then
        local backupName = args[2]
        
        local success, message = exports[GetCurrentResourceName()]:CreateBackup(source, backupName, true, true, true)
        
        TriggerClientEvent('nora:notification', source, {
            type = success and "success" or "error",
            title = success and "Backup Created" or "Backup Failed",
            message = message,
            duration = 5000
        })
    elseif subCommand == "help" then
        TriggerClientEvent('nora:notification', source, {
            type = "info",
            title = "Nora Panel Commands",
            message = "Available commands: panel, ban, kick, heal, revive, freeze, tp, bring, goto, weather, time, announce, staff, backup, help",
            duration = 10000
        })
    else
        TriggerClientEvent('nora:notification', source, {
            type = "error",
            title = "Invalid Command",
            message = "Use /nora help for available commands",
            duration = 5000
        })
    end
end, false)

-- Register admin ACE permissions
RegisterCommand('noraadmin', function(source, args, rawCommand)
    if source == 0 then
        print("^1[Nora Panel]^7 This command can only be used by players")
        return
    end
    
    local playerName = GetPlayerName(source)
    local playerIdentifier = GetPlayerIdentifier(source)
    
    -- Give admin permissions
    ExecuteCommand("add_ace player." .. playerIdentifier .. " nora.admin allow")
    
    TriggerClientEvent('nora:notification', source, {
        type = "success",
        title = "Admin Access Granted",
        message = "You now have admin access to Nora Panel",
        duration = 5000
    })
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "admin",
        "Admin access granted",
        playerIdentifier,
        playerName,
        nil,
        nil,
        "Admin access granted via command",
        GetPlayerEndpoint(source)
    )
end, false)

-- Initialize the panel
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds after resource start
    noraPanel.Initialize()
end)

-- Export functions
exports('Initialize', noraPanel.Initialize)