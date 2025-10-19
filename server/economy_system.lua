-- Advanced Economy System for Nora Panel
local economySystem = {}

-- Give money to player
function economySystem.GiveMoney(source, targetId, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to give money using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            if account == "bank" then
                xPlayer.addAccountMoney('bank', amount)
            else
                xPlayer.addMoney(amount)
            end
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "economy",
                "Money given",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Amount: $" .. amount .. " | Account: " .. (account or "cash"),
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "success",
                title = "Money Received",
                message = "You received $" .. amount .. " in your " .. (account or "cash") .. " account",
                duration = 5000
            })
            
            return true, "Money given successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Remove money from player
function economySystem.RemoveMoney(source, targetId, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to remove money using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            if account == "bank" then
                xPlayer.removeAccountMoney('bank', amount)
            else
                xPlayer.removeMoney(amount)
            end
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "economy",
                "Money removed",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Amount: $" .. amount .. " | Account: " .. (account or "cash"),
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "warning",
                title = "Money Removed",
                message = "$" .. amount .. " was removed from your " .. (account or "cash") .. " account",
                duration = 5000
            })
            
            return true, "Money removed successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Set player money
function economySystem.SetMoney(source, targetId, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local targetIdentifier = GetPlayerIdentifier(targetId)
    local targetName = GetPlayerName(targetId)
    
    -- Try to set money using ESX
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            if account == "bank" then
                xPlayer.setAccountMoney('bank', amount)
            else
                xPlayer.setMoney(amount)
            end
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "economy",
                "Money set",
                targetIdentifier,
                targetName,
                adminIdentifier,
                adminName,
                "Amount: $" .. amount .. " | Account: " .. (account or "cash"),
                GetPlayerEndpoint(source)
            )
            
            -- Notify the player
            TriggerClientEvent('nora:notification', targetId, {
                type = "info",
                title = "Money Set",
                message = "Your " .. (account or "cash") .. " account has been set to $" .. amount,
                duration = 5000
            })
            
            return true, "Money set successfully"
        end
    end
    
    return false, "ESX not available or player not found"
end

-- Get player money
function economySystem.GetPlayerMoney(targetId)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(targetId)
        if xPlayer then
            return {
                cash = xPlayer.getMoney(),
                bank = xPlayer.getAccount('bank').money,
                dirty = xPlayer.getAccount('black_money').money
            }
        end
    end
    
    return nil
end

-- Give money to all players
function economySystem.GiveMoneyToAll(source, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local players = GetPlayers()
    local successCount = 0
    
    for _, playerId in ipairs(players) do
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                if account == "bank" then
                    xPlayer.addAccountMoney('bank', amount)
                else
                    xPlayer.addMoney(amount)
                end
                successCount = successCount + 1
            end
        end
    end
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "economy",
        "Money given to all players",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Amount: $" .. amount .. " | Account: " .. (account or "cash") .. " | Players: " .. successCount,
        GetPlayerEndpoint(source)
    )
    
    return true, "Money given to " .. successCount .. " players successfully"
end

-- Remove money from all players
function economySystem.RemoveMoneyFromAll(source, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local players = GetPlayers()
    local successCount = 0
    
    for _, playerId in ipairs(players) do
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                if account == "bank" then
                    xPlayer.removeAccountMoney('bank', amount)
                else
                    xPlayer.removeMoney(amount)
                end
                successCount = successCount + 1
            end
        end
    end
    
    -- Log the action
    exports[GetCurrentResourceName()]:AddLog(
        "economy",
        "Money removed from all players",
        nil,
        nil,
        adminIdentifier,
        adminName,
        "Amount: $" .. amount .. " | Account: " .. (account or "cash") .. " | Players: " .. successCount,
        GetPlayerEndpoint(source)
    )
    
    return true, "Money removed from " .. successCount .. " players successfully"
end

-- Get economy statistics
function economySystem.GetEconomyStats()
    local players = GetPlayers()
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
function economySystem.GetTopPlayersByMoney(limit)
    local players = GetPlayers()
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

-- Transfer money between players
function economySystem.TransferMoney(source, fromId, toId, amount, account)
    local adminIdentifier = GetPlayerIdentifier(source)
    local adminName = GetPlayerName(source)
    local fromIdentifier = GetPlayerIdentifier(fromId)
    local fromName = GetPlayerName(fromId)
    local toIdentifier = GetPlayerIdentifier(toId)
    local toName = GetPlayerName(toId)
    
    -- Try to transfer money using ESX
    if ESX then
        local fromPlayer = ESX.GetPlayerFromId(fromId)
        local toPlayer = ESX.GetPlayerFromId(toId)
        
        if fromPlayer and toPlayer then
            if account == "bank" then
                fromPlayer.removeAccountMoney('bank', amount)
                toPlayer.addAccountMoney('bank', amount)
            else
                fromPlayer.removeMoney(amount)
                toPlayer.addMoney(amount)
            end
            
            -- Log the action
            exports[GetCurrentResourceName()]:AddLog(
                "economy",
                "Money transferred",
                fromIdentifier,
                fromName,
                adminIdentifier,
                adminName,
                "Amount: $" .. amount .. " | From: " .. fromName .. " | To: " .. toName .. " | Account: " .. (account or "cash"),
                GetPlayerEndpoint(source)
            )
            
            -- Notify players
            TriggerClientEvent('nora:notification', fromId, {
                type = "warning",
                title = "Money Transferred",
                message = "$" .. amount .. " was transferred from your " .. (account or "cash") .. " account to " .. toName,
                duration = 5000
            })
            
            TriggerClientEvent('nora:notification', toId, {
                type = "success",
                title = "Money Received",
                message = "You received $" .. amount .. " in your " .. (account or "cash") .. " account from " .. fromName,
                duration = 5000
            })
            
            return true, "Money transferred successfully"
        end
    end
    
    return false, "ESX not available or players not found"
end

-- Export functions
exports('GiveMoney', economySystem.GiveMoney)
exports('RemoveMoney', economySystem.RemoveMoney)
exports('SetMoney', economySystem.SetMoney)
exports('GetPlayerMoney', economySystem.GetPlayerMoney)
exports('GiveMoneyToAll', economySystem.GiveMoneyToAll)
exports('RemoveMoneyFromAll', economySystem.RemoveMoneyFromAll)
exports('GetEconomyStats', economySystem.GetEconomyStats)
exports('GetTopPlayersByMoney', economySystem.GetTopPlayersByMoney)
exports('TransferMoney', economySystem.TransferMoney)