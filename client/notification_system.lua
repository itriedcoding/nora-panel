-- Notification System for Nora Panel
local notificationSystem = {}

-- Notification queue
local notificationQueue = {}
local maxNotifications = 5
local notificationDuration = 5000

-- Show notification
function notificationSystem.ShowNotification(type, title, message, duration)
    local notification = {
        id = GetGameTimer(),
        type = type or "info",
        title = title or "Notification",
        message = message or "",
        duration = duration or notificationDuration,
        timestamp = GetGameTimer(),
        visible = true
    }
    
    -- Add to queue
    table.insert(notificationQueue, notification)
    
    -- Limit queue size
    if #notificationQueue > maxNotifications then
        table.remove(notificationQueue, 1)
    end
    
    -- Send to UI
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    -- Auto remove after duration
    Citizen.CreateThread(function()
        Citizen.Wait(notification.duration)
        notificationSystem.RemoveNotification(notification.id)
    end)
end

-- Remove notification
function notificationSystem.RemoveNotification(id)
    for i, notification in ipairs(notificationQueue) do
        if notification.id == id then
            table.remove(notificationQueue, i)
            break
        end
    end
    
    -- Send remove to UI
    SendNUIMessage({
        type = "removeNotification",
        data = {id = id}
    })
end

-- Clear all notifications
function notificationSystem.ClearAllNotifications()
    notificationQueue = {}
    
    SendNUIMessage({
        type = "clearNotifications"
    })
end

-- Get notification queue
function notificationSystem.GetNotificationQueue()
    return notificationQueue
end

-- Show success notification
function notificationSystem.ShowSuccess(title, message, duration)
    notificationSystem.ShowNotification("success", title, message, duration)
end

-- Show error notification
function notificationSystem.ShowError(title, message, duration)
    notificationSystem.ShowNotification("error", title, message, duration)
end

-- Show warning notification
function notificationSystem.ShowWarning(title, message, duration)
    notificationSystem.ShowNotification("warning", title, message, duration)
end

-- Show info notification
function notificationSystem.ShowInfo(title, message, duration)
    notificationSystem.ShowNotification("info", title, message, duration)
end

-- Show loading notification
function notificationSystem.ShowLoading(title, message)
    local notification = {
        id = GetGameTimer(),
        type = "loading",
        title = title or "Loading",
        message = message or "Please wait...",
        duration = 0, -- No auto-remove
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Hide loading notification
function notificationSystem.HideLoading(id)
    notificationSystem.RemoveNotification(id)
end

-- Show progress notification
function notificationSystem.ShowProgress(title, message, progress)
    local notification = {
        id = GetGameTimer(),
        type = "progress",
        title = title or "Progress",
        message = message or "",
        progress = progress or 0,
        duration = 0, -- No auto-remove
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Update progress notification
function notificationSystem.UpdateProgress(id, progress, message)
    for i, notification in ipairs(notificationQueue) do
        if notification.id == id then
            notification.progress = progress
            if message then
                notification.message = message
            end
            
            SendNUIMessage({
                type = "updateNotification",
                data = notification
            })
            break
        end
    end
end

-- Show confirmation notification
function notificationSystem.ShowConfirmation(title, message, onConfirm, onCancel)
    local notification = {
        id = GetGameTimer(),
        type = "confirmation",
        title = title or "Confirmation",
        message = message or "Are you sure?",
        duration = 0, -- No auto-remove
        timestamp = GetGameTimer(),
        visible = true,
        onConfirm = onConfirm,
        onCancel = onCancel
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show input notification
function notificationSystem.ShowInput(title, message, placeholder, onSubmit, onCancel)
    local notification = {
        id = GetGameTimer(),
        type = "input",
        title = title or "Input",
        message = message or "Enter value:",
        placeholder = placeholder or "",
        duration = 0, -- No auto-remove
        timestamp = GetGameTimer(),
        visible = true,
        onSubmit = onSubmit,
        onCancel = onCancel
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show toast notification
function notificationSystem.ShowToast(message, type, duration)
    local notification = {
        id = GetGameTimer(),
        type = "toast",
        title = "",
        message = message,
        duration = duration or 3000,
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show system notification
function notificationSystem.ShowSystemNotification(title, message, type)
    local notification = {
        id = GetGameTimer(),
        type = "system",
        title = title or "System",
        message = message or "",
        duration = 10000,
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show achievement notification
function notificationSystem.ShowAchievement(title, message, icon)
    local notification = {
        id = GetGameTimer(),
        type = "achievement",
        title = title or "Achievement Unlocked",
        message = message or "",
        icon = icon or "trophy",
        duration = 8000,
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show announcement notification
function notificationSystem.ShowAnnouncement(title, message, type)
    local notification = {
        id = GetGameTimer(),
        type = "announcement",
        title = title or "Announcement",
        message = message or "",
        duration = 15000,
        timestamp = GetGameTimer(),
        visible = true
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Show notification with action
function notificationSystem.ShowActionNotification(title, message, actionText, onAction)
    local notification = {
        id = GetGameTimer(),
        type = "action",
        title = title or "Action Required",
        message = message or "",
        actionText = actionText or "Action",
        duration = 0, -- No auto-remove
        timestamp = GetGameTimer(),
        visible = true,
        onAction = onAction
    }
    
    table.insert(notificationQueue, notification)
    
    SendNUIMessage({
        type = "notification",
        data = notification
    })
    
    return notification.id
end

-- Get notification statistics
function notificationSystem.GetNotificationStats()
    local stats = {
        total = #notificationQueue,
        byType = {},
        visible = 0,
        hidden = 0
    }
    
    for _, notification in ipairs(notificationQueue) do
        if stats.byType[notification.type] then
            stats.byType[notification.type] = stats.byType[notification.type] + 1
        else
            stats.byType[notification.type] = 1
        end
        
        if notification.visible then
            stats.visible = stats.visible + 1
        else
            stats.hidden = stats.hidden + 1
        end
    end
    
    return stats
end

-- Set notification position
function notificationSystem.SetPosition(position)
    SendNUIMessage({
        type = "setNotificationPosition",
        data = {position = position}
    })
end

-- Set notification theme
function notificationSystem.SetTheme(theme)
    SendNUIMessage({
        type = "setNotificationTheme",
        data = {theme = theme}
    })
end

-- Set notification sound
function notificationSystem.SetSound(enabled, volume)
    SendNUIMessage({
        type = "setNotificationSound",
        data = {
            enabled = enabled,
            volume = volume or 0.5
        }
    })
end

-- Export functions
exports('ShowNotification', notificationSystem.ShowNotification)
exports('RemoveNotification', notificationSystem.RemoveNotification)
exports('ClearAllNotifications', notificationSystem.ClearAllNotifications)
exports('GetNotificationQueue', notificationSystem.GetNotificationQueue)
exports('ShowSuccess', notificationSystem.ShowSuccess)
exports('ShowError', notificationSystem.ShowError)
exports('ShowWarning', notificationSystem.ShowWarning)
exports('ShowInfo', notificationSystem.ShowInfo)
exports('ShowLoading', notificationSystem.ShowLoading)
exports('HideLoading', notificationSystem.HideLoading)
exports('ShowProgress', notificationSystem.ShowProgress)
exports('UpdateProgress', notificationSystem.UpdateProgress)
exports('ShowConfirmation', notificationSystem.ShowConfirmation)
exports('ShowInput', notificationSystem.ShowInput)
exports('ShowToast', notificationSystem.ShowToast)
exports('ShowSystemNotification', notificationSystem.ShowSystemNotification)
exports('ShowAchievement', notificationSystem.ShowAchievement)
exports('ShowAnnouncement', notificationSystem.ShowAnnouncement)
exports('ShowActionNotification', notificationSystem.ShowActionNotification)
exports('GetNotificationStats', notificationSystem.GetNotificationStats)
exports('SetPosition', notificationSystem.SetPosition)
exports('SetTheme', notificationSystem.SetTheme)
exports('SetSound', notificationSystem.SetSound)