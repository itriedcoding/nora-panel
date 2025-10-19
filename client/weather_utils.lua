-- Weather Utility Functions for Nora Panel
local weatherUtils = {}

-- Set weather
function weatherUtils.SetWeather(weatherType, transition)
    local transition = transition or 0
    
    -- Set weather
    SetWeatherTypeOvertimePersist(weatherType, transition)
    
    weatherUtils.ShowNotification("success", "Weather Changed", "Weather changed to " .. weatherType)
end

-- Get current weather
function weatherUtils.GetCurrentWeather()
    return GetPrevWeatherTypeHashName()
end

-- Get current time
function weatherUtils.GetCurrentTime()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local second = GetClockSeconds()
    
    return {
        hour = hour,
        minute = minute,
        second = second
    }
end

-- Set time
function weatherUtils.SetTime(hour, minute, second)
    local hour = hour or 12
    local minute = minute or 0
    local second = second or 0
    
    -- Set time
    NetworkOverrideClockTime(hour, minute, second)
    
    weatherUtils.ShowNotification("success", "Time Changed", "Time changed to " .. hour .. ":" .. minute .. ":" .. second)
end

-- Freeze time
function weatherUtils.FreezeTime(freeze)
    if freeze then
        FreezeClockTime(true)
        weatherUtils.ShowNotification("info", "Time Frozen", "Time frozen")
    else
        FreezeClockTime(false)
        weatherUtils.ShowNotification("info", "Time Unfrozen", "Time unfrozen")
    end
end

-- Freeze weather
function weatherUtils.FreezeWeather(freeze)
    if freeze then
        SetWeatherTypeNowPersist(GetPrevWeatherTypeHashName())
        weatherUtils.ShowNotification("info", "Weather Frozen", "Weather frozen")
    else
        weatherUtils.ShowNotification("info", "Weather Unfrozen", "Weather unfrozen")
    end
end

-- Set wind
function weatherUtils.SetWind(windSpeed, windDirection)
    local windSpeed = windSpeed or 0.0
    local windDirection = windDirection or 0.0
    
    -- Set wind
    SetWindSpeed(windSpeed)
    SetWindDirection(windDirection)
    
    weatherUtils.ShowNotification("success", "Wind Changed", "Wind speed: " .. windSpeed .. ", direction: " .. windDirection)
end

-- Set blackout
function weatherUtils.SetBlackout(blackout)
    if blackout then
        SetArtificialLightsState(true)
        weatherUtils.ShowNotification("info", "Blackout Enabled", "Blackout enabled")
    else
        SetArtificialLightsState(false)
        weatherUtils.ShowNotification("info", "Blackout Disabled", "Blackout disabled")
    end
end

-- Get weather types
function weatherUtils.GetWeatherTypes()
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

-- Get weather presets
function weatherUtils.GetWeatherPresets()
    return {
        {name = "sunny", displayName = "Sunny Day"},
        {name = "rainy", displayName = "Rainy Day"},
        {name = "stormy", displayName = "Stormy Weather"},
        {name = "foggy", displayName = "Foggy Morning"},
        {name = "snowy", displayName = "Snowy Day"},
        {name = "night", displayName = "Night Time"}
    }
end

-- Set weather preset
function weatherUtils.SetWeatherPreset(presetName)
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
        weatherUtils.ShowNotification("error", "Error", "Preset not found")
        return false
    end
    
    -- Apply preset
    weatherUtils.SetWeather(preset.weather, 0)
    weatherUtils.SetTime(preset.time.hour, preset.time.minute, preset.time.second)
    weatherUtils.SetWind(preset.wind.speed, preset.wind.direction)
    
    weatherUtils.ShowNotification("success", "Preset Applied", "Weather preset applied: " .. presetName)
    
    return true
end

-- Reset weather
function weatherUtils.ResetWeather()
    -- Reset to default weather
    SetWeatherTypeNow("CLEAR")
    SetClockTime(12, 0, 0)
    SetWindSpeed(0.0)
    SetWindDirection(0.0)
    SetArtificialLightsState(false)
    
    weatherUtils.ShowNotification("success", "Weather Reset", "Weather reset to default")
end

-- Get weather info
function weatherUtils.GetWeatherInfo()
    local weather = weatherUtils.GetCurrentWeather()
    local time = weatherUtils.GetCurrentTime()
    local windSpeed = GetWindSpeed()
    local windDirection = GetWindDirection()
    local isBlackout = GetArtificialLightsState()
    
    return {
        weather = weather,
        time = time,
        wind = {
            speed = windSpeed,
            direction = windDirection
        },
        blackout = isBlackout
    }
end

-- Get weather forecast
function weatherUtils.GetWeatherForecast()
    -- This is a placeholder for weather forecast
    -- In a real implementation, you would get this from a weather API
    return {
        current = weatherUtils.GetWeatherInfo(),
        forecast = {
            {time = "1 hour", weather = "CLEAR", temperature = 25},
            {time = "2 hours", weather = "CLOUDS", temperature = 23},
            {time = "3 hours", weather = "RAIN", temperature = 20},
            {time = "4 hours", weather = "CLEARING", temperature = 22}
        }
    }
end

-- Set custom weather
function weatherUtils.SetCustomWeather(weatherData)
    if weatherData.weather then
        weatherUtils.SetWeather(weatherData.weather, weatherData.transition or 0)
    end
    
    if weatherData.time then
        weatherUtils.SetTime(weatherData.time.hour, weatherData.time.minute, weatherData.time.second)
    end
    
    if weatherData.wind then
        weatherUtils.SetWind(weatherData.wind.speed, weatherData.wind.direction)
    end
    
    if weatherData.blackout ~= nil then
        weatherUtils.SetBlackout(weatherData.blackout)
    end
    
    weatherUtils.ShowNotification("success", "Custom Weather Set", "Custom weather applied")
end

-- Get weather statistics
function weatherUtils.GetWeatherStats()
    local weather = weatherUtils.GetCurrentWeather()
    local time = weatherUtils.GetCurrentTime()
    local windSpeed = GetWindSpeed()
    local windDirection = GetWindDirection()
    local isBlackout = GetArtificialLightsState()
    
    return {
        currentWeather = weather,
        currentTime = time,
        windSpeed = windSpeed,
        windDirection = windDirection,
        blackout = isBlackout,
        isDay = time.hour >= 6 and time.hour < 18,
        isNight = time.hour >= 18 or time.hour < 6,
        isRaining = weather == "RAIN" or weather == "THUNDER" or weather == "CLEARING",
        isSnowing = weather == "SNOWLIGHT" or weather == "BLIZZARD" or weather == "XMAS",
        isFoggy = weather == "FOGGY" or weather == "SMOG"
    }
end

-- Show notification
function weatherUtils.ShowNotification(type, title, message)
    if Config.Notifications.enabled then
        SendNUIMessage({
            type = "notification",
            data = {
                type = type,
                title = title,
                message = message,
                duration = Config.Notifications.duration
            }
        })
    end
end

-- Export functions
exports('SetWeather', weatherUtils.SetWeather)
exports('GetCurrentWeather', weatherUtils.GetCurrentWeather)
exports('GetCurrentTime', weatherUtils.GetCurrentTime)
exports('SetTime', weatherUtils.SetTime)
exports('FreezeTime', weatherUtils.FreezeTime)
exports('FreezeWeather', weatherUtils.FreezeWeather)
exports('SetWind', weatherUtils.SetWind)
exports('SetBlackout', weatherUtils.SetBlackout)
exports('GetWeatherTypes', weatherUtils.GetWeatherTypes)
exports('GetWeatherPresets', weatherUtils.GetWeatherPresets)
exports('SetWeatherPreset', weatherUtils.SetWeatherPreset)
exports('ResetWeather', weatherUtils.ResetWeather)
exports('GetWeatherInfo', weatherUtils.GetWeatherInfo)
exports('GetWeatherForecast', weatherUtils.GetWeatherForecast)
exports('SetCustomWeather', weatherUtils.SetCustomWeather)
exports('GetWeatherStats', weatherUtils.GetWeatherStats)