-- Advanced Performance Monitor for Nora Panel
local performanceMonitor = {}

-- Performance data
local performanceData = {
    fps = 0,
    ping = 0,
    memory = 0,
    cpu = 0,
    uptime = 0,
    players = 0,
    vehicles = 0,
    entities = 0
}

-- Start performance monitoring
function performanceMonitor.StartMonitoring()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000) -- Update every 5 seconds
            
            -- Get server FPS
            performanceData.fps = GetServerTickRate()
            
            -- Get server ping (average of all players)
            local players = GetPlayers()
            local totalPing = 0
            local pingCount = 0
            
            for _, playerId in ipairs(players) do
                local ping = GetPlayerPing(playerId)
                if ping > 0 then
                    totalPing = totalPing + ping
                    pingCount = pingCount + 1
                end
            end
            
            performanceData.ping = pingCount > 0 and (totalPing / pingCount) or 0
            performanceData.players = #players
            
            -- Get memory usage
            performanceData.memory = GetGameTimer() -- This is a placeholder, actual memory monitoring would require additional tools
            
            -- Get CPU usage (placeholder)
            performanceData.cpu = GetGameTimer() -- This is a placeholder, actual CPU monitoring would require additional tools
            
            -- Get uptime
            performanceData.uptime = GetGameTimer()
            
            -- Get vehicle count
            local vehicleList = GetGamePool('CVehicle')
            performanceData.vehicles = #vehicleList
            
            -- Get entity count
            local entityList = GetGamePool('CObject')
            performanceData.entities = #entityList
            
            -- Save to database
            exports[GetCurrentResourceName()]:UpdateServerStats(
                performanceData.players,
                performanceData.players, -- Total players (same as online for now)
                performanceData.fps,
                performanceData.ping,
                performanceData.memory,
                performanceData.cpu,
                performanceData.uptime
            )
            
            -- Check for performance alerts
            performanceMonitor.CheckAlerts()
        end
    end)
end

-- Check performance alerts
function performanceMonitor.CheckAlerts()
    local alerts = Config.Features.performanceMonitor.alertThresholds
    
    -- FPS alert
    if performanceData.fps < alerts.fps then
        performanceMonitor.SendAlert("low_fps", "Server FPS is low: " .. performanceData.fps .. " (threshold: " .. alerts.fps .. ")")
    end
    
    -- Ping alert
    if performanceData.ping > alerts.ping then
        performanceMonitor.SendAlert("high_ping", "Average ping is high: " .. performanceData.ping .. "ms (threshold: " .. alerts.ping .. "ms)")
    end
    
    -- Memory alert
    if performanceData.memory > alerts.memory then
        performanceMonitor.SendAlert("high_memory", "Memory usage is high: " .. performanceData.memory .. "% (threshold: " .. alerts.memory .. "%)")
    end
    
    -- CPU alert
    if performanceData.cpu > alerts.cpu then
        performanceMonitor.SendAlert("high_cpu", "CPU usage is high: " .. performanceData.cpu .. "% (threshold: " .. alerts.cpu .. "%)")
    end
end

-- Send performance alert
function performanceMonitor.SendAlert(type, message)
    -- Log the alert
    exports[GetCurrentResourceName()]:AddLog(
        "performance",
        "Performance Alert",
        nil,
        nil,
        nil,
        nil,
        "Type: " .. type .. " | Message: " .. message,
        "127.0.0.1"
    )
    
    -- Notify admins
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if IsPlayerAceAllowed(playerId, "nora.admin") then
            TriggerClientEvent('nora:notification', playerId, {
                type = "warning",
                title = "Performance Alert",
                message = message,
                duration = 10000
            })
        end
    end
end

-- Get current performance data
function performanceMonitor.GetCurrentPerformance()
    return performanceData
end

-- Get performance history
function performanceMonitor.GetPerformanceHistory(limit)
    return exports[GetCurrentResourceName()]:GetServerStats(limit or 100)
end

-- Get performance statistics
function performanceMonitor.GetPerformanceStats()
    local history = performanceMonitor.GetPerformanceHistory(100)
    
    if #history == 0 then
        return {
            averageFPS = 0,
            averagePing = 0,
            averageMemory = 0,
            averageCPU = 0,
            maxFPS = 0,
            minFPS = 0,
            maxPing = 0,
            minPing = 0,
            maxMemory = 0,
            minMemory = 0,
            maxCPU = 0,
            minCPU = 0,
            totalSamples = 0
        }
    end
    
    local stats = {
        totalFPS = 0,
        totalPing = 0,
        totalMemory = 0,
        totalCPU = 0,
        maxFPS = 0,
        minFPS = math.huge,
        maxPing = 0,
        minPing = math.huge,
        maxMemory = 0,
        minMemory = math.huge,
        maxCPU = 0,
        minCPU = math.huge,
        totalSamples = #history
    }
    
    for _, data in ipairs(history) do
        stats.totalFPS = stats.totalFPS + data.server_fps
        stats.totalPing = stats.totalPing + data.server_ping
        stats.totalMemory = stats.totalMemory + data.memory_usage
        stats.totalCPU = stats.totalCPU + data.cpu_usage
        
        stats.maxFPS = math.max(stats.maxFPS, data.server_fps)
        stats.minFPS = math.min(stats.minFPS, data.server_fps)
        stats.maxPing = math.max(stats.maxPing, data.server_ping)
        stats.minPing = math.min(stats.minPing, data.server_ping)
        stats.maxMemory = math.max(stats.maxMemory, data.memory_usage)
        stats.minMemory = math.min(stats.minMemory, data.memory_usage)
        stats.maxCPU = math.max(stats.maxCPU, data.cpu_usage)
        stats.minCPU = math.min(stats.minCPU, data.cpu_usage)
    end
    
    stats.averageFPS = stats.totalFPS / stats.totalSamples
    stats.averagePing = stats.totalPing / stats.totalSamples
    stats.averageMemory = stats.totalMemory / stats.totalSamples
    stats.averageCPU = stats.totalCPU / stats.totalSamples
    
    return stats
end

-- Get player performance data
function performanceMonitor.GetPlayerPerformance(playerId)
    local player = GetPlayerPed(playerId)
    if not player then
        return nil
    end
    
    local ping = GetPlayerPing(playerId)
    local coords = GetEntityCoords(player)
    local health = GetEntityHealth(player)
    local armor = GetPedArmour(player)
    
    return {
        id = playerId,
        name = GetPlayerName(playerId),
        ping = ping,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        health = health,
        armor = armor,
        connected = true
    }
end

-- Get all players performance
function performanceMonitor.GetAllPlayersPerformance()
    local players = GetPlayers()
    local performance = {}
    
    for _, playerId in ipairs(players) do
        local playerPerf = performanceMonitor.GetPlayerPerformance(playerId)
        if playerPerf then
            table.insert(performance, playerPerf)
        end
    end
    
    return performance
end

-- Get server resources
function performanceMonitor.GetServerResources()
    local resources = {}
    
    -- Get all resources
    local resourceList = GetNumResources()
    for i = 0, resourceList - 1 do
        local resourceName = GetResourceByFindIndex(i)
        local resourceState = GetResourceState(resourceName)
        
        table.insert(resources, {
            name = resourceName,
            state = resourceState,
            running = resourceState == "started"
        })
    end
    
    return resources
end

-- Get resource performance
function performanceMonitor.GetResourcePerformance(resourceName)
    local resourceState = GetResourceState(resourceName)
    
    if resourceState ~= "started" then
        return nil
    end
    
    -- This would require additional monitoring tools
    -- For now, return basic info
    return {
        name = resourceName,
        state = resourceState,
        memory = 0, -- Placeholder
        cpu = 0, -- Placeholder
        uptime = 0 -- Placeholder
    }
end

-- Get performance recommendations
function performanceMonitor.GetPerformanceRecommendations()
    local recommendations = {}
    local current = performanceMonitor.GetCurrentPerformance()
    
    -- FPS recommendations
    if current.fps < 30 then
        table.insert(recommendations, {
            type = "fps",
            severity = "high",
            message = "Server FPS is very low. Consider reducing resource count or optimizing scripts.",
            action = "Check for resource conflicts or heavy scripts"
        })
    elseif current.fps < 50 then
        table.insert(recommendations, {
            type = "fps",
            severity = "medium",
            message = "Server FPS is below optimal. Monitor resource usage.",
            action = "Consider optimizing heavy resources"
        })
    end
    
    -- Ping recommendations
    if current.ping > 200 then
        table.insert(recommendations, {
            type = "ping",
            severity = "high",
            message = "Average ping is very high. Check server location and network.",
            action = "Consider moving server closer to players or upgrading network"
        })
    elseif current.ping > 100 then
        table.insert(recommendations, {
            type = "ping",
            severity = "medium",
            message = "Average ping is elevated. Monitor network performance.",
            action = "Check for network issues or server load"
        })
    end
    
    -- Memory recommendations
    if current.memory > 80 then
        table.insert(recommendations, {
            type = "memory",
            severity = "high",
            message = "Memory usage is high. Consider restarting server or optimizing resources.",
            action = "Check for memory leaks in resources"
        })
    elseif current.memory > 60 then
        table.insert(recommendations, {
            type = "memory",
            severity = "medium",
            message = "Memory usage is elevated. Monitor resource memory consumption.",
            action = "Review resource memory usage"
        })
    end
    
    return recommendations
end

-- Export functions
exports('StartMonitoring', performanceMonitor.StartMonitoring)
exports('GetCurrentPerformance', performanceMonitor.GetCurrentPerformance)
exports('GetPerformanceHistory', performanceMonitor.GetPerformanceHistory)
exports('GetPerformanceStats', performanceMonitor.GetPerformanceStats)
exports('GetPlayerPerformance', performanceMonitor.GetPlayerPerformance)
exports('GetAllPlayersPerformance', performanceMonitor.GetAllPlayersPerformance)
exports('GetServerResources', performanceMonitor.GetServerResources)
exports('GetResourcePerformance', performanceMonitor.GetResourcePerformance)
exports('GetPerformanceRecommendations', performanceMonitor.GetPerformanceRecommendations)

-- Start monitoring when resource starts
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds after resource start
    performanceMonitor.StartMonitoring()
end)