lib.callback.register('px_crafting:getItemCount', function(source, item)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local hasEnoughItems = true
    for k, v in pairs(item) do
        local c = exports.ox_inventory:GetItem(src, v.itemName, nil, false)
        debug(c.label .. " " .. c.count)
    
        if c.count < v.quantity then
            hasEnoughItems = false
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                title = 'You do not have: ' .. c.label.." Required "..v.quantity,
                position = 'top',
                description = '',
                5000
            })
        end
    end

    if hasEnoughItems then
        local info = {}
        info.value = true
        info.xp = GetPlayerXp()
        debug(info)
        return info
    else
        local info = {}
        info.value = false
        return info
    end
end)

RegisterNetEvent('px_crafting:removeItem')
AddEventHandler('px_crafting:removeItem', function(item, weapon)
    for k,v in pairs(item) do
        exports.ox_inventory:RemoveItem(source, v.itemName, v.quantity, nil, nil)
    end
    if Crafting.XpSystem then
        exports.ox_inventory:AddItem(source, weapon, 1, nil, nil)
        GivePlayerXp(source, Crafting.ExperiancePerCraft)
    else
        exports.ox_inventory:AddItem(source, weapon, 1, nil, nil)
    end
end)

RegisterCommand("givecraftingxp", function(source, args, rawCommand)
    local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
    if args[1] ~= nil then
        if args[2] ~= nil then
            if xTarget ~= nil then
                local player_xp = MySQL.scalar.await('SELECT `crafting_level` FROM `users` WHERE `identifier` = ?', {
                    xTarget.identifier
                })
                local givexp = player_xp + tonumber(args[2])
                local affectedRows = MySQL.update.await('UPDATE users SET `crafting_level` = ? WHERE identifier = ?', {
                    givexp, xTarget.identifier
                })
            else
                debug('User not found')
            end
        end
    end
end, false)