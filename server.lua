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
        exports["px_weapon-crafting"]:addPlayerXp(source, Crafting.ExperiancePerCraft)
    else
        exports.ox_inventory:AddItem(source, weapon, 1, nil, nil)
    end
end)

RegisterNetEvent('px_crafting:SaveTable')
AddEventHandler('px_crafting:SaveTable', function(name, coordsx, coordsy, coordsz, heading)
    local loadFile= LoadResourceFile(GetCurrentResourceName(), "./positionTable.json")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            debug(extract)
            table.insert(extract, {name = name, coords = vector3(coordsx, coordsy, coordsz), heading = heading})
            SaveResourceFile(GetCurrentResourceName(), "positionTable.json",  json.encode(extract, { indent = true }), -1)
        else
            local Table = {}
            table.insert(Table, {name = name, coords = vector3(coordsx, coordsy, coordsz), heading = heading})
            SaveResourceFile(GetCurrentResourceName(), "positionTable.json",  json.encode(Table, { indent = true }), -1)
        end
    end
end)

RegisterNetEvent('px_weapon_crafting:DeleteEntity')
AddEventHandler('px_weapon_crafting:DeleteEntity', function(coords, name)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./positionTable.json ")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            for k,v in ipairs(extract) do
                if v.name == name then
                    debug(v.coords)
                    debug(k)
                    table.remove(extract, k)
                    SaveResourceFile(GetCurrentResourceName(), "positionTable.json",  json.encode(extract, { indent = true }), -1)
                end
            end
        end
    end
end)

lib.callback.register('px_crafting:getTablePosition', function(source)
    local loadFile= LoadResourceFile(GetCurrentResourceName(), "./positionTable.json")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        return extract
    end
end)

RegisterCommand(Crafting.CommandGive, function(source, args, rawCommand)
    local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
    if args[1] ~= nil then
        if args[2] ~= nil then
            if xTarget ~= nil then
                exports["px_weapon-crafting"]:addPlayerXp(xTarget.source, args[2])
            else
                debug('User not found')
            end
        end
    end
end, false)

RegisterCommand(Crafting.Command, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(Crafting.PermissionCommand) do
        if v == xPlayer.getGroup() then
            debug(v)
            TriggerClientEvent('px_crafting:placeProp', source, Crafting.PropBench)
            return
        end
    end
end)

RegisterCommand(Crafting.CommandShow, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(Crafting.PermissionCommand) do
        if v == xPlayer.getGroup() then
            debug(v)
            TriggerClientEvent('px_crafting:showCrafting', source)
            return
        end
    end
end)

exports("addPlayerXp", function(source, xp)
    local xPlayer = ESX.GetPlayerFromId(source)
    local player_xp = MySQL.scalar.await('SELECT `crafting_level` FROM `users` WHERE `identifier` = ?', {
        xPlayer.identifier
    })
    local givexp = player_xp + tonumber(xp)
    local affectedRows = MySQL.update.await('UPDATE users SET `crafting_level` = ? WHERE identifier = ?', {
        givexp, xPlayer.identifier
    })

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = lang.notify_earned_xp.." "..Crafting.ExperiancePerCraft.."xp",
        position = 'top',
        description = '',
        5000
    })
end)
