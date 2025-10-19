-- Client Configuration for Nora Panel
Config = {}

-- Panel Configuration
Config.PanelName = "Nora Panel"
Config.PanelVersion = "1.0.0"
Config.PanelAuthor = "Nora Development Team"

-- Key bindings
Config.Keys = {
    openPanel = 344, -- F1 key
    closePanel = 27, -- ESC key
    toggleSpectate = 73, -- I key
    toggleFreeze = 70, -- F key
    toggleNoclip = 78, -- N key
    teleportToMarker = 47, -- G key
    teleportToWaypoint = 38 -- E key
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

-- Spectate Configuration
Config.Spectate = {
    enabled = true,
    cameraHeight = 10.0,
    cameraDistance = 5.0,
    cameraSpeed = 2.0,
    freecamSpeed = 0.5
}

-- Noclip Configuration
Config.Noclip = {
    enabled = true,
    speed = 0.5,
    speedMultiplier = 2.0,
    maxSpeed = 10.0,
    minSpeed = 0.1
}

-- Teleport Configuration
Config.Teleport = {
    enabled = true,
    fadeTime = 1000,
    fadeInTime = 500,
    fadeOutTime = 500
}

-- Vehicle Configuration
Config.Vehicle = {
    enabled = true,
    maxSpawnDistance = 50.0,
    maxDeleteDistance = 10.0,
    repairTime = 3000
}

-- Weapon Configuration
Config.Weapon = {
    enabled = true,
    maxAmmo = 9999,
    defaultAmmo = 250
}

-- Weather Configuration
Config.Weather = {
    enabled = true,
    transitionTime = 10000,
    freezeTime = false,
    freezeWeather = false
}

-- Economy Configuration
Config.Economy = {
    enabled = true,
    maxMoney = 1000000,
    minMoney = 0
}

-- Logging Configuration
Config.Logging = {
    enabled = true,
    logActions = true,
    logTeleports = true,
    logVehicleSpawns = true,
    logWeaponGives = true
}

-- Security Configuration
Config.Security = {
    enabled = true,
    antiCheat = true,
    antiSpam = true,
    maxActionsPerMinute = 10
}

-- Performance Configuration
Config.Performance = {
    enabled = true,
    updateInterval = 1000,
    maxFPS = 60,
    minFPS = 30
}

-- Backup Configuration
Config.Backup = {
    enabled = true,
    autoBackup = true,
    backupInterval = 3600000 -- 1 hour in milliseconds
}

-- API Configuration
Config.API = {
    enabled = true,
    baseURL = "http://localhost:3000/api",
    timeout = 10000,
    retries = 3
}

-- Feature Configuration
Config.Features = {
    -- Player Management
    playerManagement = {
        enabled = true,
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
    
    -- Vehicle Management
    vehicleManagement = {
        enabled = true,
        allowSpawn = true,
        allowDelete = true,
        allowRepair = true,
        allowModify = true,
        allowTeleport = true,
        allowBring = true
    },
    
    -- Weapon Management
    weaponManagement = {
        enabled = true,
        allowGive = true,
        allowRemove = true,
        allowAmmo = true,
        allowComponents = true
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
        allowPresets = true
    },
    
    -- Economy System
    economySystem = {
        enabled = true,
        allowGiveMoney = true,
        allowRemoveMoney = true,
        allowSetMoney = true,
        allowGiveBank = true,
        allowRemoveBank = true,
        allowSetBank = true
    },
    
    -- Announcement System
    announcementSystem = {
        enabled = true,
        allowGlobal = true,
        allowPlayer = true,
        allowStaff = true
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
        logAdminActions = true
    },
    
    -- Backup System
    backupSystem = {
        enabled = true,
        autoBackup = true,
        allowManual = true,
        allowRestore = true,
        allowDelete = true
    },
    
    -- Performance Monitor
    performanceMonitor = {
        enabled = true,
        monitorFPS = true,
        monitorPing = true,
        monitorMemory = true,
        monitorCPU = true
    },
    
    -- Security System
    securitySystem = {
        enabled = true,
        antiCheat = true,
        antiSpam = true,
        antiExploit = true
    }
}

-- Debug Configuration
Config.Debug = {
    enabled = false,
    logLevel = "INFO",
    showFPS = false,
    showPing = false,
    showMemory = false
}

-- Localization
Config.Locale = {
    -- Common
    ["yes"] = "Yes",
    ["no"] = "No",
    ["ok"] = "OK",
    ["cancel"] = "Cancel",
    ["confirm"] = "Confirm",
    ["close"] = "Close",
    ["save"] = "Save",
    ["delete"] = "Delete",
    ["edit"] = "Edit",
    ["add"] = "Add",
    ["remove"] = "Remove",
    ["search"] = "Search",
    ["filter"] = "Filter",
    ["sort"] = "Sort",
    ["refresh"] = "Refresh",
    ["loading"] = "Loading...",
    ["error"] = "Error",
    ["success"] = "Success",
    ["warning"] = "Warning",
    ["info"] = "Information",
    
    -- Panel
    ["panel_title"] = "Nora Panel",
    ["panel_subtitle"] = "Advanced Admin Panel",
    ["panel_version"] = "Version 1.0.0",
    ["panel_author"] = "Nora Development Team",
    
    -- Navigation
    ["nav_dashboard"] = "Dashboard",
    ["nav_players"] = "Players",
    ["nav_vehicles"] = "Vehicles",
    ["nav_weapons"] = "Weapons",
    ["nav_teleport"] = "Teleport",
    ["nav_weather"] = "Weather",
    ["nav_economy"] = "Economy",
    ["nav_announcements"] = "Announcements",
    ["nav_logs"] = "Logs",
    ["nav_backups"] = "Backups",
    ["nav_performance"] = "Performance",
    ["nav_security"] = "Security",
    ["nav_settings"] = "Settings",
    
    -- Players
    ["players_title"] = "Player Management",
    ["players_online"] = "Online Players",
    ["players_total"] = "Total Players",
    ["players_name"] = "Name",
    ["players_id"] = "ID",
    ["players_ping"] = "Ping",
    ["players_health"] = "Health",
    ["players_armor"] = "Armor",
    ["players_money"] = "Money",
    ["players_bank"] = "Bank",
    ["players_job"] = "Job",
    ["players_group"] = "Group",
    ["players_coords"] = "Coordinates",
    ["players_actions"] = "Actions",
    
    -- Actions
    ["action_ban"] = "Ban",
    ["action_kick"] = "Kick",
    ["action_heal"] = "Heal",
    ["action_revive"] = "Revive",
    ["action_freeze"] = "Freeze",
    ["action_spectate"] = "Spectate",
    ["action_teleport"] = "Teleport",
    ["action_bring"] = "Bring",
    ["action_goto"] = "Go To",
    ["action_set_health"] = "Set Health",
    ["action_set_armor"] = "Set Armor",
    ["action_set_money"] = "Set Money",
    ["action_set_bank"] = "Set Bank",
    ["action_set_job"] = "Set Job",
    ["action_set_group"] = "Set Group",
    
    -- Vehicles
    ["vehicles_title"] = "Vehicle Management",
    ["vehicles_spawn"] = "Spawn Vehicle",
    ["vehicles_delete"] = "Delete Vehicle",
    ["vehicles_repair"] = "Repair Vehicle",
    ["vehicles_modify"] = "Modify Vehicle",
    ["vehicles_teleport"] = "Teleport to Vehicle",
    ["vehicles_bring"] = "Bring Vehicle",
    ["vehicles_lock"] = "Lock Vehicle",
    ["vehicles_unlock"] = "Unlock Vehicle",
    ["vehicles_engine"] = "Toggle Engine",
    ["vehicles_lights"] = "Toggle Lights",
    ["vehicles_siren"] = "Toggle Siren",
    
    -- Weapons
    ["weapons_title"] = "Weapon Management",
    ["weapons_give"] = "Give Weapon",
    ["weapons_remove"] = "Remove Weapon",
    ["weapons_ammo"] = "Set Ammo",
    ["weapons_component"] = "Add Component",
    ["weapons_remove_component"] = "Remove Component",
    
    -- Teleport
    ["teleport_title"] = "Teleport System",
    ["teleport_to_player"] = "Teleport to Player",
    ["teleport_player"] = "Teleport Player",
    ["teleport_to_coords"] = "Teleport to Coordinates",
    ["teleport_to_marker"] = "Teleport to Marker",
    ["teleport_bring"] = "Bring Player",
    ["teleport_goto"] = "Go to Player",
    ["teleport_save"] = "Save Location",
    ["teleport_load"] = "Load Location",
    
    -- Weather
    ["weather_title"] = "Weather Control",
    ["weather_current"] = "Current Weather",
    ["weather_set"] = "Set Weather",
    ["weather_freeze"] = "Freeze Weather",
    ["weather_preset"] = "Weather Preset",
    ["weather_time"] = "Set Time",
    ["weather_freeze_time"] = "Freeze Time",
    ["weather_blackout"] = "Blackout",
    
    -- Economy
    ["economy_title"] = "Economy System",
    ["economy_give_money"] = "Give Money",
    ["economy_remove_money"] = "Remove Money",
    ["economy_set_money"] = "Set Money",
    ["economy_give_bank"] = "Give Bank",
    ["economy_remove_bank"] = "Remove Bank",
    ["economy_set_bank"] = "Set Bank",
    ["economy_transfer"] = "Transfer Money",
    
    -- Announcements
    ["announcements_title"] = "Announcement System",
    ["announcements_create"] = "Create Announcement",
    ["announcements_global"] = "Global Announcement",
    ["announcements_staff"] = "Staff Announcement",
    ["announcements_player"] = "Player Announcement",
    ["announcements_title_field"] = "Title",
    ["announcements_message_field"] = "Message",
    ["announcements_type_field"] = "Type",
    ["announcements_target_field"] = "Target",
    
    -- Logs
    ["logs_title"] = "Log System",
    ["logs_recent"] = "Recent Logs",
    ["logs_search"] = "Search Logs",
    ["logs_filter"] = "Filter Logs",
    ["logs_export"] = "Export Logs",
    ["logs_clear"] = "Clear Logs",
    
    -- Backups
    ["backups_title"] = "Backup System",
    ["backups_create"] = "Create Backup",
    ["backups_restore"] = "Restore Backup",
    ["backups_delete"] = "Delete Backup",
    ["backups_auto"] = "Auto Backup",
    ["backups_manual"] = "Manual Backup",
    
    -- Performance
    ["performance_title"] = "Performance Monitor",
    ["performance_fps"] = "FPS",
    ["performance_ping"] = "Ping",
    ["performance_memory"] = "Memory",
    ["performance_cpu"] = "CPU",
    ["performance_uptime"] = "Uptime",
    ["performance_players"] = "Players",
    ["performance_vehicles"] = "Vehicles",
    ["performance_entities"] = "Entities",
    
    -- Security
    ["security_title"] = "Security System",
    ["security_events"] = "Security Events",
    ["security_alerts"] = "Security Alerts",
    ["security_recommendations"] = "Recommendations",
    ["security_ban_suspicious"] = "Ban Suspicious Player",
    ["security_kick_suspicious"] = "Kick Suspicious Player",
    
    -- Settings
    ["settings_title"] = "Settings",
    ["settings_general"] = "General",
    ["settings_ui"] = "UI",
    ["settings_notifications"] = "Notifications",
    ["settings_sounds"] = "Sounds",
    ["settings_keybinds"] = "Keybinds",
    ["settings_performance"] = "Performance",
    ["settings_security"] = "Security",
    
    -- Notifications
    ["notification_success"] = "Success",
    ["notification_error"] = "Error",
    ["notification_warning"] = "Warning",
    ["notification_info"] = "Information",
    
    -- Messages
    ["message_player_not_found"] = "Player not found",
    ["message_invalid_id"] = "Invalid player ID",
    ["message_no_permission"] = "You don't have permission to perform this action",
    ["message_action_success"] = "Action completed successfully",
    ["message_action_failed"] = "Action failed",
    ["message_confirm_action"] = "Are you sure you want to perform this action?",
    ["message_enter_reason"] = "Enter reason",
    ["message_enter_amount"] = "Enter amount",
    ["message_enter_coords"] = "Enter coordinates",
    ["message_enter_message"] = "Enter message",
    ["message_enter_title"] = "Enter title",
    
    -- Errors
    ["error_unknown"] = "An unknown error occurred",
    ["error_network"] = "Network error",
    ["error_timeout"] = "Request timeout",
    ["error_server"] = "Server error",
    ["error_client"] = "Client error",
    ["error_permission"] = "Permission denied",
    ["error_invalid_data"] = "Invalid data",
    ["error_missing_data"] = "Missing required data",
    ["error_validation"] = "Validation error"
}