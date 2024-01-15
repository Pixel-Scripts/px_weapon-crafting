function debug(...)
    if Crafting.EnableDebug then
        local args = { ... }

        for i = 1, #args do
            local arg = args[i]
            args[i] = type(arg) == 'table' and json.encode(arg, { sort_keys = true, indent = true }) or tostring(arg)
        end

        print('^1[DEBUG] ^7', table.concat(args, '\t'))
    end
end

function GetJobPlayer()
    return ESX.PlayerData.job.name
end

function GetPlayerXp()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local player_xp = MySQL.scalar.await('SELECT `crafting_level` FROM `users` WHERE `identifier` = ?', {
        xPlayer.identifier
    })
    return player_xp
end

function GivePlayerXp(source, xp)
    local xPlayer = ESX.GetPlayerFromId(source)
    local getPlayerXp = GetPlayerXp()
    local total_xp = getPlayerXp + xp
    local affectedRows = MySQL.update.await('UPDATE users SET `crafting_level` = ? WHERE identifier = ?', {
        total_xp, xPlayer.identifier
    })
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = lang.notify_earned_xp.." "..Crafting.ExperiancePerCraft.."xp",
        position = 'top',
        description = '',
        5000
    })
end