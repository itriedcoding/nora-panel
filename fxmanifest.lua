fx_version 'cerulean'
game 'gta5'

author 'Nora Panel Development Team'
description 'Advanced FiveM Admin Panel with 30+ Features'
version '1.0.0'

-- Server Scripts
server_scripts {
    'server/config.lua',
    'server/database.lua',
    'server/logger.lua',
    'server/ban_system.lua',
    'server/kick_system.lua',
    'server/player_management.lua',
    'server/vehicle_management.lua',
    'server/weapon_management.lua',
    'server/teleport_system.lua',
    'server/weather_control.lua',
    'server/economy_system.lua',
    'server/announcement_system.lua',
    'server/backup_system.lua',
    'server/performance_monitor.lua',
    'server/security_system.lua',
    'server/api_server.lua',
    'server/main.lua'
}

-- Client Scripts
client_scripts {
    'client/config.lua',
    'client/player_utils.lua',
    'client/vehicle_utils.lua',
    'client/weapon_utils.lua',
    'client/teleport_utils.lua',
    'client/weather_utils.lua',
    'client/economy_utils.lua',
    'client/notification_system.lua',
    'client/main.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/css/animations.css',
    'html/js/app.js',
    'html/js/api.js',
    'html/js/components.js',
    'html/js/notifications.js',
    'html/js/charts.js',
    'html/js/utils.js',
    'html/assets/images/*.png',
    'html/assets/icons/*.svg',
    'html/assets/sounds/*.ogg'
}

-- Dependencies
dependencies {
    'mysql-async',
    'es_extended'
}

-- Exports
exports {
    'GetPlayerData',
    'GetServerStats',
    'LogAction',
    'BanPlayer',
    'KickPlayer'
}

-- Server Exports
server_exports {
    'GetPlayerData',
    'GetServerStats',
    'LogAction',
    'BanPlayer',
    'KickPlayer'
}