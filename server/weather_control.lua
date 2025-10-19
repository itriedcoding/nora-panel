-- Advanced Weather Control System for Nora Panel
local weatherControl = {}

-- Set weather
function weatherControl.SetWeather(source, weatherType, transition)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Set weather for all players
    TriggerClientEvent('nora:setWeather', -1, weatherType, transition or 0)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Weather changed",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Weather: " .. weatherType .. (transition and " | Transition: " .. transition or ""),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weather changed to " .. weatherType .. " successfully"
end

-- Set weather for specific player
function weatherControl.SetWeatherForPlayer(source, targetId, weatherType, transition)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Set weather for specific player
    TriggerClientEvent('nora:setWeather', targetId, weatherType, transition or 0)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Weather changed for player",
        targetIdentifier,
        targetName,
        adminIdentifier,
        adminName,
        "Weather: " .. weatherType .. (transition and " | Transition: " .. transition or ""),
        GetPlayerEndpoint(source)
    )
    
    return true, "Weather changed for " .. targetName .. " successfully"
end

-- Freeze weather
function weatherControl.FreezeWeather(source, freeze)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Freeze/unfreeze weather for all players
    TriggerClientEvent('nora:freezeWeather', -1, freeze)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        freeze and "Weather frozen" or "Weather unfrozen",
        nil,
        nil,
        adminIdentifier,
        adminName,
        freeze and "Weather frozen" or "Weather unfrozen",
        GetPlayerEndpoint(source)
    )
    
    return true, (freeze and "Weather frozen" or "Weather unfrozen") .. " successfully"
end

-- Set wind
function weatherControl.SetWind(source, windSpeed, windDirection)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Set wind for all players
    TriggerClientEvent('nora:setWind', -1, windSpeed, windDirection)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Wind changed",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Wind Speed: " .. windSpeed .. " | Wind Direction: " .. windDirection,
        GetPlayerEndpoint(source)
    )
    
    return true, "Wind changed successfully"
end

-- Set time
function weatherControl.SetTime(source, hour, minute, second)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Set time for all players
    TriggerClientEvent('nora:setTime', -1, hour, minute, second)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Time changed",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Time: " .. hour .. ":" .. minute .. ":" .. second,
        GetPlayerEndpoint(source)
    )
    
    return true, "Time changed to " .. hour .. ":" .. minute .. ":" .. second .. " successfully"
end

-- Freeze time
function weatherControl.FreezeTime(source, freeze)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Freeze/unfreeze time for all players
    TriggerClientEvent('nora:freezeTime', -1, freeze)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        freeze and "Time frozen" or "Time unfrozen",
        nil,
        nil,
        adminIdentifier,
        adminName,
        freeze and "Time frozen" or "Time unfrozen",
        GetPlayerEndpoint(source)
    )
    
    return true, (freeze and "Time frozen" or "Time unfrozen") .. " successfully"
end

-- Set blackout
function weatherControl.SetBlackout(source, blackout)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Set blackout for all players
    TriggerClientEvent('nora:setBlackout', -1, blackout)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        blackout and "Blackout enabled" or "Blackout disabled",
        nil,
        nil,
        adminIdentifier,
        adminName,
        blackout and "Blackout enabled" or "Blackout disabled",
        GetPlayerEndpoint(source)
    )
    
    return true, (blackout and "Blackout enabled" or "Blackout disabled") .. " successfully"
end

-- Get weather types
function weatherControl.GetWeatherTypes()
    return {
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
end

-- Get current weather
function weatherControl.GetCurrentWeather()
    return GetPrevWeatherTypeHashName()
end

-- Get current time
function weatherControl.GetCurrentTime()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local second = GetClockSeconds()
    
    return {
        hour = hour,
        minute = minute,
        second = second
    }
end

-- Set weather preset
function weatherControl.SetWeatherPreset(source, presetName)
    local presets = {
        ["sunny"] = {
            weather = "EXTRASUNNY",
            time = {hour = 12, minute = 0, second = 0},
            wind = {speed = 0.0, direction = 0.0}
        },
        ["rainy"] = {
            weather = "RAIN",
            time = {hour = 14, minute = 0, second = 0},
            wind = {speed = 0.5, direction = 45.0}
        },
        ["stormy"] = {
            weather = "THUNDER",
            time = {hour = 16, minute = 0, second = 0},
            wind = {speed = 1.0, direction = 90.0}
        },
        ["foggy"] = {
            weather = "FOGGY",
            time = {hour = 6, minute = 0, second = 0},
            wind = {speed = 0.2, direction = 0.0}
        },
        ["snowy"] = {
            weather = "SNOWLIGHT",
            time = {hour = 10, minute = 0, second = 0},
            wind = {speed = 0.3, direction = 180.0}
        },
        ["night"] = {
            weather = "CLEAR",
            time = {hour = 22, minute = 0, second = 0},
            wind = {speed = 0.1, direction = 0.0}
        }
    }
    
    local preset = presets[presetName]
    if not preset then
        return false, "Preset not found"
    end
    
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Apply preset to all players
    TriggerClientEvent('nora:setWeather', -1, preset.weather, 0)
    TriggerClientEvent('nora:setTime', -1, preset.time.hour, preset.time.minute, preset.time.second)
    TriggerClientEvent('nora:setWind', -1, preset.wind.speed, preset.wind.direction)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Weather preset applied",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Preset: " .. presetName,
        GetPlayerEndpoint(source)
    )
    
    return true, "Weather preset " .. presetName .. " applied successfully"
end

-- Get weather presets
function weatherControl.GetWeatherPresets()
    return {
        {name = "sunny", displayName = "Sunny Day"},
        {name = "rainy", displayName = "Rainy Day"},
        {name = "stormy", displayName = "Stormy Weather"},
        {name = "foggy", displayName = "Foggy Morning"},
        {name = "snowy", displayName = "Snowy Day"},
        {name = "night", displayName = "Night Time"}
    }
end

-- Reset weather
function weatherControl.ResetWeather(source)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    
    -- Reset weather to default
    TriggerClientEvent('nora:resetWeather', -1)
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "weather",
        "Weather reset",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Weather reset to default",
        GetPlayerEndpoint(source)
    )
    
    return true, "Weather reset successfully"
end

-- Export functions
exports('SetWeather', weatherControl.SetWeather)
exports('SetWeatherForPlayer', weatherControl.SetWeatherForPlayer)
exports('FreezeWeather', weatherControl.FreezeWeather)
exports('SetWind', weatherControl.SetWind)
exports('SetTime', weatherControl.SetTime)
exports('FreezeTime', weatherControl.FreezeTime)
exports('SetBlackout', weatherControl.SetBlackout)
exports('GetWeatherTypes', weatherControl.GetWeatherTypes)
exports('GetCurrentWeather', weatherControl.GetCurrentWeather)
exports('GetCurrentTime', weatherControl.GetCurrentTime)
exports('SetWeatherPreset', weatherControl.SetWeatherPreset)
exports('GetWeatherPresets', weatherControl.GetWeatherPresets)
exports('ResetWeather', weatherControl.ResetWeather)