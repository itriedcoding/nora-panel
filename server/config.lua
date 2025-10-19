Config = {}

-- Panel Configuration
Config.PanelName = "Nora Panel"
Config.PanelVersion = "1.0.0"
Config.PanelAuthor = "Nora Development Team"

-- Database Configuration
Config.Database = {
    host = "localhost",
    database = "nora_panel",
    username = "root",
    password = "",
    port = 3306
}

-- Security Configuration
Config.Security = {
    enableAntiCheat = true,
    enableLogging = true,
    enableBackup = true,
    maxLoginAttempts = 5,
    sessionTimeout = 3600, -- 1 hour in seconds
    requireTwoFactor = false,
    allowedIPs = {}, -- Empty means all IPs allowed
    blockedIPs = {}
}

-- Panel Access Levels
Config.AccessLevels = {
    ["superadmin"] = {
        level = 5,
        permissions = {
            "ban_players",
            "kick_players",
            "manage_players",
            "manage_vehicles",
            "manage_weapons",
            "teleport_players",
            "control_weather",
            "manage_economy",
            "view_logs",
            "manage_announcements",
            "backup_data",
            "monitor_performance",
            "security_management",
            "api_access"
        }
    },
    ["admin"] = {
        level = 4,
        permissions = {
            "kick_players",
            "manage_players",
            "view_logs",
            "manage_announcements"
        }
    },
    ["moderator"] = {
        level = 3,
        permissions = {
            "kick_players",
            "view_logs"
        }
    },
    ["helper"] = {
        level = 2,
        permissions = {
            "view_logs"
        }
    }
}

-- Feature Configuration
Config.Features = {
    -- Player Management
    playerManagement = {
        enabled = true,
        maxPlayers = 128,
        allowSpectate = true,
        allowFreeze = true,
        allowHeal = true,
        allowRevive = true,
        allowSetHealth = true,
        allowSetArmor = true,
        allowSetMoney = true,
        allowSetJob = true,
        allowSetGroup = true
    },
    
    -- Ban System
    banSystem = {
        enabled = true,
        permanentBans = true,
        temporaryBans = true,
        banReasons = {
            "Cheating/Hacking",
            "Exploiting",
            "Griefing",
            "Inappropriate Behavior",
            "Spamming",
            "RDM (Random Death Match)",
            "VDM (Vehicle Death Match)",
            "Other"
        },
        maxBanDuration = 365 -- days
    },
    
    -- Kick System
    kickSystem = {
        enabled = true,
        kickReasons = {
            "Inappropriate Behavior",
            "Spamming",
            "AFK",
            "Connection Issues",
            "Other"
        }
    },
    
    -- Vehicle Management
    vehicleManagement = {
        enabled = true,
        allowSpawn = true,
        allowDelete = true,
        allowRepair = true,
        allowModify = true,
        maxVehiclesPerPlayer = 5,
        blacklistedVehicles = {}
    },
    
    -- Weapon Management
    weaponManagement = {
        enabled = true,
        allowGive = true,
        allowRemove = true,
        allowAmmo = true,
        blacklistedWeapons = {}
    },
    
    -- Teleport System
    teleportSystem = {
        enabled = true,
        allowTeleportToPlayer = true,
        allowTeleportPlayer = true,
        allowTeleportToCoords = true,
        allowTeleportToMarker = true,
        allowBringPlayer = true,
        allowGoToPlayer = true
    },
    
    -- Weather Control
    weatherControl = {
        enabled = true,
        allowChange = true,
        allowFreeze = true,
        weatherTypes = {
            "CLEAR",
            "EXTRASUNNY",
            "CLOUDS",
            "OVERCAST",
            "RAIN",
            "CLEARING",
            "THUNDER",
            "SMOG",
            "FOGGY",
            "XMAS",
            "SNOWLIGHT",
            "BLIZZARD"
        }
    },
    
    -- Economy System
    economySystem = {
        enabled = true,
        allowGiveMoney = true,
        allowRemoveMoney = true,
        allowSetMoney = true,
        allowGiveBank = true,
        allowRemoveBank = true,
        allowSetBank = true,
        maxMoneyAmount = 1000000
    },
    
    -- Announcement System
    announcementSystem = {
        enabled = true,
        allowGlobal = true,
        allowPlayer = true,
        allowStaff = true,
        maxMessageLength = 500
    },
    
    -- Logging System
    loggingSystem = {
        enabled = true,
        logActions = true,
        logChat = true,
        logConnections = true,
        logDisconnections = true,
        logDeaths = true,
        logKills = true,
        logCommands = true,
        logAdminActions = true,
        maxLogEntries = 10000
    },
    
    -- Backup System
    backupSystem = {
        enabled = true,
        autoBackup = true,
        backupInterval = 3600, -- 1 hour
        maxBackups = 10,
        backupPath = "backups/"
    },
    
    -- Performance Monitor
    performanceMonitor = {
        enabled = true,
        monitorFPS = true,
        monitorPing = true,
        monitorMemory = true,
        monitorCPU = true,
        alertThresholds = {
            fps = 30,
            ping = 200,
            memory = 80,
            cpu = 80
        }
    },
    
    -- Security System
    securitySystem = {
        enabled = true,
        antiCheat = true,
        antiSpam = true,
        antiExploit = true,
        ipWhitelist = false,
        ipBlacklist = true,
        maxConnectionsPerIP = 3
    }
}

-- API Configuration
Config.API = {
    enabled = true,
    port = 3000,
    rateLimit = {
        enabled = true,
        maxRequests = 100,
        windowMs = 60000 -- 1 minute
    },
    authentication = {
        enabled = true,
        requireToken = true,
        tokenExpiry = 3600 -- 1 hour
    },
    endpoints = {
        players = "/api/players",
        bans = "/api/bans",
        kicks = "/api/kicks",
        logs = "/api/logs",
        stats = "/api/stats",
        actions = "/api/actions"
    }
}

-- Notification Configuration
Config.Notifications = {
    enabled = true,
    position = "top-right",
    duration = 5000,
    types = {
        success = { color = "#4CAF50", icon = "check" },
        error = { color = "#F44336", icon = "error" },
        warning = { color = "#FF9800", icon = "warning" },
        info = { color = "#2196F3", icon = "info" }
    }
}

-- UI Configuration
Config.UI = {
    theme = {
        primary = "#1a1a2e",
        secondary = "#16213e",
        accent = "#0f3460",
        text = "#e94560",
        success = "#4CAF50",
        warning = "#FF9800",
        error = "#F44336",
        info = "#2196F3"
    },
    animations = {
        enabled = true,
        duration = 300,
        easing = "ease-in-out"
    },
    sounds = {
        enabled = true,
        volume = 0.5,
        sounds = {
            notification = "notification.ogg",
            success = "success.ogg",
            error = "error.ogg",
            warning = "warning.ogg"
        }
    }
}