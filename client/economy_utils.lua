-- Economy Utility Functions for Nora Panel
local economyUtils = {}

-- Get player money
function economyUtils.GetPlayerMoney()
    local money = 0
    local bank = 0
    local dirty = 0
    
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            money = xPlayer.money or 0
            bank = xPlayer.accounts and xPlayer.accounts.bank and xPlayer.accounts.bank.money or 0
            dirty = xPlayer.accounts and xPlayer.accounts.black_money and xPlayer.accounts.black_money.money or 0
        end
    end
    
    return {
        cash = money,
        bank = bank,
        dirty = dirty,
        total = money + bank + dirty
    }
end

-- Give money
function economyUtils.GiveMoney(amount, account)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            if account == "bank" then
                xPlayer.addAccountMoney('bank', amount)
            else
                xPlayer.addMoney(amount)
            end
            
            economyUtils.ShowNotification("success", "Money Received", "You received $" .. amount .. " in your " .. (account or "cash") .. " account")
        end
    end
end

-- Remove money
function economyUtils.RemoveMoney(amount, account)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            if account == "bank" then
                xPlayer.removeAccountMoney('bank', amount)
            else
                xPlayer.removeMoney(amount)
            end
            
            economyUtils.ShowNotification("warning", "Money Removed", "$" .. amount .. " was removed from your " .. (account or "cash") .. " account")
        end
    end
end

-- Set money
function economyUtils.SetMoney(amount, account)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            if account == "bank" then
                xPlayer.setAccountMoney('bank', amount)
            else
                xPlayer.setMoney(amount)
            end
            
            economyUtils.ShowNotification("info", "Money Set", "Your " .. (account or "cash") .. " account has been set to $" .. amount)
        end
    end
end

-- Transfer money
function economyUtils.TransferMoney(fromAccount, toAccount, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer then
            if fromAccount == "cash" and toAccount == "bank" then
                xPlayer.removeMoney(amount)
                xPlayer.addAccountMoney('bank', amount)
            elseif fromAccount == "bank" and toAccount == "cash" then
                xPlayer.removeAccountMoney('bank', amount)
                xPlayer.addMoney(amount)
            else
                economyUtils.ShowNotification("error", "Error", "Invalid transfer accounts")
                return false
            end
            
            economyUtils.ShowNotification("success", "Money Transferred", "Transferred $" .. amount .. " from " .. fromAccount .. " to " .. toAccount)
        end
    end
end

-- Get economy statistics
function economyUtils.GetEconomyStats()
    local players = GetActivePlayers()
    local totalCash = 0
    local totalBank = 0
    local totalDirty = 0
    local playerCount = 0
    
    for _, playerId in ipairs(players) do
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                totalCash = totalCash + xPlayer.getMoney()
                totalBank = totalBank + xPlayer.getAccount('bank').money
                totalDirty = totalDirty + xPlayer.getAccount('black_money').money
                playerCount = playerCount + 1
            end
        end
    end
    
    return {
        totalCash = totalCash,
        totalBank = totalBank,
        totalDirty = totalDirty,
        totalMoney = totalCash + totalBank + totalDirty,
        playerCount = playerCount,
        averageCash = playerCount > 0 and (totalCash / playerCount) or 0,
        averageBank = playerCount > 0 and (totalBank / playerCount) or 0,
        averageDirty = playerCount > 0 and (totalDirty / playerCount) or 0
    }
end

-- Get top players by money
function economyUtils.GetTopPlayersByMoney(limit)
    local players = GetActivePlayers()
    local playerMoney = {}
    
    for _, playerId in ipairs(players) do
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                local totalMoney = xPlayer.getMoney() + xPlayer.getAccount('bank').money + xPlayer.getAccount('black_money').money
                table.insert(playerMoney, {
                    id = playerId,
                    name = GetPlayerName(playerId),
                    cash = xPlayer.getMoney(),
                    bank = xPlayer.getAccount('bank').money,
                    dirty = xPlayer.getAccount('black_money').money,
                    total = totalMoney
                })
            end
        end
    end
    
    -- Sort by total money
    table.sort(playerMoney, function(a, b) return a.total > b.total end)
    
    -- Return top players
    local result = {}
    for i = 1, math.min(limit or 10, #playerMoney) do
        table.insert(result, playerMoney[i])
    end
    
    return result
end

-- Get money history
function economyUtils.GetMoneyHistory()
    -- This would require additional tracking
    -- For now, return empty array
    return {}
end

-- Get transaction log
function economyUtils.GetTransactionLog()
    -- This would require additional tracking
    -- For now, return empty array
    return {}
end

-- Format money
function economyUtils.FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return "$" .. formatted
end

-- Get money breakdown
function economyUtils.GetMoneyBreakdown()
    local money = economyUtils.GetPlayerMoney()
    
    return {
        cash = {
            amount = money.cash,
            formatted = economyUtils.FormatMoney(money.cash),
            percentage = money.total > 0 and (money.cash / money.total * 100) or 0
        },
        bank = {
            amount = money.bank,
            formatted = economyUtils.FormatMoney(money.bank),
            percentage = money.total > 0 and (money.bank / money.total * 100) or 0
        },
        dirty = {
            amount = money.dirty,
            formatted = economyUtils.FormatMoney(money.dirty),
            percentage = money.total > 0 and (money.dirty / money.total * 100) or 0
        },
        total = {
            amount = money.total,
            formatted = economyUtils.FormatMoney(money.total)
        }
    }
end

-- Get economy trends
function economyUtils.GetEconomyTrends()
    -- This would require historical data tracking
    -- For now, return placeholder data
    return {
        cashTrend = "stable",
        bankTrend = "increasing",
        dirtyTrend = "decreasing",
        totalTrend = "increasing"
    }
end

-- Get economy alerts
function economyUtils.GetEconomyAlerts()
    local alerts = {}
    local money = economyUtils.GetPlayerMoney()
    
    -- Check for low cash
    if money.cash < 1000 then
        table.insert(alerts, {
            type = "warning",
            message = "Low cash balance: $" .. money.cash
        })
    end
    
    -- Check for low bank
    if money.bank < 5000 then
        table.insert(alerts, {
            type = "info",
            message = "Low bank balance: $" .. money.bank
        })
    end
    
    -- Check for high dirty money
    if money.dirty > 10000 then
        table.insert(alerts, {
            type = "warning",
            message = "High dirty money balance: $" .. money.dirty
        })
    end
    
    return alerts
end

-- Get economy recommendations
function economyUtils.GetEconomyRecommendations()
    local recommendations = {}
    local money = economyUtils.GetPlayerMoney()
    
    -- Cash recommendations
    if money.cash > money.bank then
        table.insert(recommendations, {
            type = "info",
            message = "Consider depositing some cash into your bank account for safety"
        })
    end
    
    -- Bank recommendations
    if money.bank < 10000 then
        table.insert(recommendations, {
            type = "info",
            message = "Consider building up your bank balance for future purchases"
        })
    end
    
    -- Dirty money recommendations
    if money.dirty > 0 then
        table.insert(recommendations, {
            type = "warning",
            message = "Consider laundering your dirty money to avoid detection"
        })
    end
    
    return recommendations
end

-- Show notification
function economyUtils.ShowNotification(type, title, message)
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
exports('GetPlayerMoney', economyUtils.GetPlayerMoney)
exports('GiveMoney', economyUtils.GiveMoney)
exports('RemoveMoney', economyUtils.RemoveMoney)
exports('SetMoney', economyUtils.SetMoney)
exports('TransferMoney', economyUtils.TransferMoney)
exports('GetEconomyStats', economyUtils.GetEconomyStats)
exports('GetTopPlayersByMoney', economyUtils.GetTopPlayersByMoney)
exports('GetMoneyHistory', economyUtils.GetMoneyHistory)
exports('GetTransactionLog', economyUtils.GetTransactionLog)
exports('FormatMoney', economyUtils.FormatMoney)
exports('GetMoneyBreakdown', economyUtils.GetMoneyBreakdown)
exports('GetEconomyTrends', economyUtils.GetEconomyTrends)
exports('GetEconomyAlerts', economyUtils.GetEconomyAlerts)
exports('GetEconomyRecommendations', economyUtils.GetEconomyRecommendations)