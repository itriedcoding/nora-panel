-- Advanced API Server for Nora Panel
local apiServer = {}

-- API endpoints
local endpoints = {
    -- Authentication
    ["/api/auth/login"] = {
        method = "POST",
        handler = apiServer.HandleLogin
    },
    ["/api/auth/logout"] = {
        method = "POST",
        handler = apiServer.HandleLogout
    },
    ["/api/auth/validate"] = {
        method = "POST",
        handler = apiServer.HandleValidate
    },
    
    -- Players
    ["/api/players"] = {
        method = "GET",
        handler = apiServer.HandleGetPlayers
    },
    ["/api/players/online"] = {
        method = "GET",
        handler = apiServer.HandleGetOnlinePlayers
    },
    ["/api/players/:id"] = {
        method = "GET",
        handler = apiServer.HandleGetPlayer
    },
    ["/api/players/:id/ban"] = {
        method = "POST",
        handler = apiServer.HandleBanPlayer
    },
    ["/api/players/:id/kick"] = {
        method = "POST",
        handler = apiServer.HandleKickPlayer
    },
    ["/api/players/:id/heal"] = {
        method = "POST",
        handler = apiServer.HandleHealPlayer
    },
    ["/api/players/:id/revive"] = {
        method = "POST",
        handler = apiServer.HandleRevivePlayer
    },
    ["/api/players/:id/freeze"] = {
        method = "POST",
        handler = apiServer.HandleFreezePlayer
    },
    ["/api/players/:id/teleport"] = {
        method = "POST",
        handler = apiServer.HandleTeleportPlayer
    },
    ["/api/players/:id/spectate"] = {
        method = "POST",
        handler = apiServer.HandleSpectatePlayer
    },
    
    -- Bans
    ["/api/bans"] = {
        method = "GET",
        handler = apiServer.HandleGetBans
    },
    ["/api/bans/:id"] = {
        method = "DELETE",
        handler = apiServer.HandleUnbanPlayer
    },
    ["/api/bans/stats"] = {
        method = "GET",
        handler = apiServer.HandleGetBanStats
    },
    
    -- Kicks
    ["/api/kicks"] = {
        method = "GET",
        handler = apiServer.HandleGetKicks
    },
    ["/api/kicks/stats"] = {
        method = "GET",
        handler = apiServer.HandleGetKickStats
    },
    
    -- Logs
    ["/api/logs"] = {
        method = "GET",
        handler = apiServer.HandleGetLogs
    },
    ["/api/logs/search"] = {
        method = "POST",
        handler = apiServer.HandleSearchLogs
    },
    ["/api/logs/stats"] = {
        method = "GET",
        handler = apiServer.HandleGetLogStats
    },
    
    -- Server Stats
    ["/api/stats"] = {
        method = "GET",
        handler = apiServer.HandleGetStats
    },
    ["/api/stats/performance"] = {
        method = "GET",
        handler = apiServer.HandleGetPerformanceStats
    },
    ["/api/stats/security"] = {
        method = "GET",
        handler = apiServer.HandleGetSecurityStats
    },
    
    -- Vehicles
    ["/api/vehicles"] = {
        method = "GET",
        handler = apiServer.HandleGetVehicles
    },
    ["/api/vehicles/spawn"] = {
        method = "POST",
        handler = apiServer.HandleSpawnVehicle
    },
    ["/api/vehicles/:id/delete"] = {
        method = "DELETE",
        handler = apiServer.HandleDeleteVehicle
    },
    ["/api/vehicles/:id/repair"] = {
        method = "POST",
        handler = apiServer.HandleRepairVehicle
    },
    
    -- Weapons
    ["/api/weapons"] = {
        method = "GET",
        handler = apiServer.HandleGetWeapons
    },
    ["/api/weapons/give"] = {
        method = "POST",
        handler = apiServer.HandleGiveWeapon
    },
    ["/api/weapons/remove"] = {
        method = "POST",
        handler = apiServer.HandleRemoveWeapon
    },
    
    -- Weather
    ["/api/weather"] = {
        method = "GET",
        handler = apiServer.HandleGetWeather
    },
    ["/api/weather/set"] = {
        method = "POST",
        handler = apiServer.HandleSetWeather
    },
    ["/api/weather/presets"] = {
        method = "GET",
        handler = apiServer.HandleGetWeatherPresets
    },
    
    -- Economy
    ["/api/economy/stats"] = {
        method = "GET",
        handler = apiServer.HandleGetEconomyStats
    },
    ["/api/economy/give"] = {
        method = "POST",
        handler = apiServer.HandleGiveMoney
    },
    ["/api/economy/remove"] = {
        method = "POST",
        handler = apiServer.HandleRemoveMoney
    },
    
    -- Announcements
    ["/api/announcements"] = {
        method = "GET",
        handler = apiServer.HandleGetAnnouncements
    },
    ["/api/announcements/create"] = {
        method = "POST",
        handler = apiServer.HandleCreateAnnouncement
    },
    ["/api/announcements/:id/delete"] = {
        method = "DELETE",
        handler = apiServer.HandleDeleteAnnouncement
    },
    
    -- Backups
    ["/api/backups"] = {
        method = "GET",
        handler = apiServer.HandleGetBackups
    },
    ["/api/backups/create"] = {
        method = "POST",
        handler = apiServer.HandleCreateBackup
    },
    ["/api/backups/:id/restore"] = {
        method = "POST",
        handler = apiServer.HandleRestoreBackup
    },
    ["/api/backups/:id/delete"] = {
        method = "DELETE",
        handler = apiServer.HandleDeleteBackup
    }
}

-- Handle API request
function apiServer.HandleRequest(method, path, data, headers)
    -- Find matching endpoint
    local endpoint = nil
    local params = {}
    
    for pattern, ep in pairs(endpoints) do
        if ep.method == method then
            local match, captures = string.match(path, pattern:gsub(":([%w_]+)", "([^/]+)"))
            if match then
                endpoint = ep
                -- Extract parameters
                local paramNames = {}
                for param in pattern:gmatch(":([%w_]+)") do
                    table.insert(paramNames, param)
                end
                for i, capture in ipairs(captures) do
                    if paramNames[i] then
                        params[paramNames[i]] = capture
                    end
                end
                break
            end
        end
    end
    
    if not endpoint then
        return apiServer.SendResponse(404, {error = "Endpoint not found"})
    end
    
    -- Check authentication
    if not apiServer.CheckAuthentication(headers) then
        return apiServer.SendResponse(401, {error = "Unauthorized"})
    end
    
    -- Call handler
    local success, result = pcall(endpoint.handler, method, path, data, headers, params)
    
    if success then
        return result
    else
        return apiServer.SendResponse(500, {error = "Internal server error: " .. tostring(result)})
    end
end

-- Check authentication
function apiServer.CheckAuthentication(headers)
    if not Config.API.authentication.enabled then
        return true
    end
    
    local token = headers["Authorization"] or headers["authorization"]
    if not token then
        return false
    end
    
    -- Remove "Bearer " prefix if present
    token = token:gsub("^Bearer ", "")
    
    -- Validate token
    local session = exports[GetCurrentResourceName()]:ValidateAdminSession(token, headers["X-Forwarded-For"] or "127.0.0.1")
    return session ~= nil
end

-- Send response
function apiServer.SendResponse(status, data)
    return {
        status = status,
        headers = {
            ["Content-Type"] = "application/json",
            ["Access-Control-Allow-Origin"] = "*",
            ["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS",
            ["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
        },
        body = json.encode(data)
    }
end

-- Authentication handlers
function apiServer.HandleLogin(method, path, data, headers, params)
    local username = data.username
    local password = data.password
    
    -- Validate credentials (implement your own authentication logic)
    if username == "admin" and password == "admin" then
        local token = apiServer.GenerateToken()
        local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + Config.API.authentication.tokenExpiry)
        
        -- Create session
        exports[GetCurrentResourceName()]:CreateAdminSession(
            "admin",
            token,
            headers["X-Forwarded-For"] or "127.0.0.1",
            headers["User-Agent"] or "Unknown",
            expiresAt
        )
        
        return apiServer.SendResponse(200, {
            success = true,
            token = token,
            expiresAt = expiresAt
        })
    else
        return apiServer.SendResponse(401, {error = "Invalid credentials"})
    end
end

function apiServer.HandleLogout(method, path, data, headers, params)
    local token = headers["Authorization"]:gsub("^Bearer ", "")
    
    -- Invalidate session
    exports[GetCurrentResourceName()]:InvalidateAdminSession(token)
    
    return apiServer.SendResponse(200, {success = true})
end

function apiServer.HandleValidate(method, path, data, headers, params)
    return apiServer.SendResponse(200, {valid = true})
end

-- Player handlers
function apiServer.HandleGetPlayers(method, path, data, headers, params)
    local players = exports[GetCurrentResourceName()]:GetAllPlayers()
    return apiServer.SendResponse(200, {players = players})
end

function apiServer.HandleGetOnlinePlayers(method, path, data, headers, params)
    local players = exports[GetCurrentResourceName()]:GetOnlinePlayers()
    return apiServer.SendResponse(200, {players = players})
end

function apiServer.HandleGetPlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local player = exports[GetCurrentResourceName()]:GetPlayerInfo(nil, playerId)
    if not player then
        return apiServer.SendResponse(404, {error = "Player not found"})
    end
    
    return apiServer.SendResponse(200, {player = player})
end

function apiServer.HandleBanPlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local reason = data.reason or "No reason provided"
    local duration = data.duration
    local permanent = data.permanent or false
    
    local success, message = exports[GetCurrentResourceName()]:BanPlayer(nil, playerId, reason, duration, permanent)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleKickPlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local reason = data.reason or "No reason provided"
    
    local success, message = exports[GetCurrentResourceName()]:KickPlayer(nil, playerId, reason)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleHealPlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:HealPlayer(nil, playerId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleRevivePlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:RevivePlayer(nil, playerId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleFreezePlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local freeze = data.freeze
    if freeze == nil then
        return apiServer.SendResponse(400, {error = "Freeze parameter required"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:FreezePlayer(nil, playerId, freeze)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleTeleportPlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local coords = data.coords
    local heading = data.heading
    
    if not coords then
        return apiServer.SendResponse(400, {error = "Coordinates required"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:TeleportPlayer(nil, playerId, coords, heading)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleSpectatePlayer(method, path, data, headers, params)
    local playerId = tonumber(params.id)
    if not playerId then
        return apiServer.SendResponse(400, {error = "Invalid player ID"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:SpectatePlayer(nil, playerId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Ban handlers
function apiServer.HandleGetBans(method, path, data, headers, params)
    local bans = exports[GetCurrentResourceName()]:GetAllBans()
    return apiServer.SendResponse(200, {bans = bans})
end

function apiServer.HandleUnbanPlayer(method, path, data, headers, params)
    local banId = tonumber(params.id)
    if not banId then
        return apiServer.SendResponse(400, {error = "Invalid ban ID"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:UnbanPlayer(nil, banId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleGetBanStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetBanStats()
    return apiServer.SendResponse(200, {stats = stats})
end

-- Kick handlers
function apiServer.HandleGetKicks(method, path, data, headers, params)
    local kicks = exports[GetCurrentResourceName()]:GetAllKicks()
    return apiServer.SendResponse(200, {kicks = kicks})
end

function apiServer.HandleGetKickStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetKickStats()
    return apiServer.SendResponse(200, {stats = stats})
end

-- Log handlers
function apiServer.HandleGetLogs(method, path, data, headers, params)
    local limit = tonumber(data.limit) or 100
    local offset = tonumber(data.offset) or 0
    local type = data.type
    
    local logs
    if type then
        logs = exports[GetCurrentResourceName()]:GetLogsByType(type, limit, offset)
    else
        logs = exports[GetCurrentResourceName()]:GetLogs(limit, offset)
    end
    
    return apiServer.SendResponse(200, {logs = logs})
end

function apiServer.HandleSearchLogs(method, path, data, headers, params)
    local query = data.query
    local limit = tonumber(data.limit) or 100
    local offset = tonumber(data.offset) or 0
    
    if not query then
        return apiServer.SendResponse(400, {error = "Query required"})
    end
    
    local logs = exports[GetCurrentResourceName()]:SearchLogs(query, limit, offset)
    return apiServer.SendResponse(200, {logs = logs})
end

function apiServer.HandleGetLogStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetLogStats()
    return apiServer.SendResponse(200, {stats = stats})
end

-- Stats handlers
function apiServer.HandleGetStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetServerStats()
    return apiServer.SendResponse(200, {stats = stats})
end

function apiServer.HandleGetPerformanceStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetPerformanceStats()
    return apiServer.SendResponse(200, {stats = stats})
end

function apiServer.HandleGetSecurityStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetSecurityStats()
    return apiServer.SendResponse(200, {stats = stats})
end

-- Vehicle handlers
function apiServer.HandleGetVehicles(method, path, data, headers, params)
    local vehicles = exports[GetCurrentResourceName()]:GetVehicleList()
    return apiServer.SendResponse(200, {vehicles = vehicles})
end

function apiServer.HandleSpawnVehicle(method, path, data, headers, params)
    local playerId = tonumber(data.playerId)
    local model = data.model
    local coords = data.coords
    local heading = data.heading
    
    if not playerId or not model or not coords then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:SpawnVehicle(nil, playerId, model, coords, heading)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleDeleteVehicle(method, path, data, headers, params)
    local vehicleId = tonumber(params.id)
    local playerId = tonumber(data.playerId)
    
    if not vehicleId or not playerId then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:DeleteVehicle(nil, playerId, vehicleId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleRepairVehicle(method, path, data, headers, params)
    local vehicleId = tonumber(params.id)
    local playerId = tonumber(data.playerId)
    
    if not vehicleId or not playerId then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:RepairVehicle(nil, playerId, vehicleId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Weapon handlers
function apiServer.HandleGetWeapons(method, path, data, headers, params)
    local weapons = exports[GetCurrentResourceName()]:GetWeaponList()
    return apiServer.SendResponse(200, {weapons = weapons})
end

function apiServer.HandleGiveWeapon(method, path, data, headers, params)
    local playerId = tonumber(data.playerId)
    local weaponHash = tonumber(data.weaponHash)
    local ammo = tonumber(data.ammo) or 250
    
    if not playerId or not weaponHash then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:GiveWeapon(nil, playerId, weaponHash, ammo)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleRemoveWeapon(method, path, data, headers, params)
    local playerId = tonumber(data.playerId)
    local weaponHash = tonumber(data.weaponHash)
    
    if not playerId or not weaponHash then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:RemoveWeapon(nil, playerId, weaponHash)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Weather handlers
function apiServer.HandleGetWeather(method, path, data, headers, params)
    local weather = exports[GetCurrentResourceName()]:GetCurrentWeather()
    local time = exports[GetCurrentResourceName()]:GetCurrentTime()
    
    return apiServer.SendResponse(200, {
        weather = weather,
        time = time
    })
end

function apiServer.HandleSetWeather(method, path, data, headers, params)
    local weatherType = data.weatherType
    local transition = data.transition
    local playerId = data.playerId
    
    if not weatherType then
        return apiServer.SendResponse(400, {error = "Weather type required"})
    end
    
    local success, message
    if playerId then
        success, message = exports[GetCurrentResourceName()]:SetWeatherForPlayer(nil, playerId, weatherType, transition)
    else
        success, message = exports[GetCurrentResourceName()]:SetWeather(nil, weatherType, transition)
    end
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleGetWeatherPresets(method, path, data, headers, params)
    local presets = exports[GetCurrentResourceName()]:GetWeatherPresets()
    return apiServer.SendResponse(200, {presets = presets})
end

-- Economy handlers
function apiServer.HandleGetEconomyStats(method, path, data, headers, params)
    local stats = exports[GetCurrentResourceName()]:GetEconomyStats()
    return apiServer.SendResponse(200, {stats = stats})
end

function apiServer.HandleGiveMoney(method, path, data, headers, params)
    local playerId = tonumber(data.playerId)
    local amount = tonumber(data.amount)
    local account = data.account or "cash"
    
    if not playerId or not amount then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:GiveMoney(nil, playerId, amount, account)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleRemoveMoney(method, path, data, headers, params)
    local playerId = tonumber(data.playerId)
    local amount = tonumber(data.amount)
    local account = data.account or "cash"
    
    if not playerId or not amount then
        return apiServer.SendResponse(400, {error = "Missing required parameters"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:RemoveMoney(nil, playerId, amount, account)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Announcement handlers
function apiServer.HandleGetAnnouncements(method, path, data, headers, params)
    local announcements = exports[GetCurrentResourceName()]:GetAllAnnouncements()
    return apiServer.SendResponse(200, {announcements = announcements})
end

function apiServer.HandleCreateAnnouncement(method, path, data, headers, params)
    local title = data.title
    local message = data.message
    local type = data.type or "info"
    local target = data.target or "all"
    local expiresAt = data.expiresAt
    
    if not title or not message then
        return apiServer.SendResponse(400, {error = "Title and message required"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:CreateAnnouncement(nil, title, message, type, target, expiresAt)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleDeleteAnnouncement(method, path, data, headers, params)
    local announcementId = tonumber(params.id)
    if not announcementId then
        return apiServer.SendResponse(400, {error = "Invalid announcement ID"})
    end
    
    local success, message = exports[GetCurrentResourceName()]:DeleteAnnouncement(nil, announcementId)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Backup handlers
function apiServer.HandleGetBackups(method, path, data, headers, params)
    local backups = exports[GetCurrentResourceName()]:ListBackups()
    return apiServer.SendResponse(200, {backups = backups})
end

function apiServer.HandleCreateBackup(method, path, data, headers, params)
    local backupName = data.backupName
    local includeDatabase = data.includeDatabase or true
    local includeLogs = data.includeLogs or true
    local includeConfig = data.includeConfig or true
    
    local success, message = exports[GetCurrentResourceName()]:CreateBackup(nil, backupName, includeDatabase, includeLogs, includeConfig)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleRestoreBackup(method, path, data, headers, params)
    local backupName = params.id
    
    local success, message = exports[GetCurrentResourceName()]:RestoreBackup(nil, backupName)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

function apiServer.HandleDeleteBackup(method, path, data, headers, params)
    local backupName = params.id
    
    local success, message = exports[GetCurrentResourceName()]:DeleteBackup(nil, backupName)
    
    if success then
        return apiServer.SendResponse(200, {success = true, message = message})
    else
        return apiServer.SendResponse(400, {error = message})
    end
end

-- Generate token
function apiServer.GenerateToken()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local token = ""
    
    for i = 1, 32 do
        local rand = math.random(1, #chars)
        token = token .. chars:sub(rand, rand)
    end
    
    return token
end

-- Export functions
exports('HandleRequest', apiServer.HandleRequest)

-- Start API server
Citizen.CreateThread(function()
    if Config.API.enabled then
        print("^2[Nora Panel]^7 API Server started on port " .. Config.API.port)
    end
end)