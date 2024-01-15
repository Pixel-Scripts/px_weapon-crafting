RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function (job)
    ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerSpawn', function()
    SpawnObject()
end)

local cam
local inCam
local objectPosition = {}

exports.ox_target:addModel("gr_prop_gr_bench_02b", {
    {
        name = 'open_crafting',
        event = '',
        icon = 'fa-solid fa-screwdriver-wrench',
        label = lang.target_label,
        onSelect = function(entity, distance, coords, name)
            local coords = GetEntityCoords(entity.entity)
            CamON(entity.entity, coords, GetEntityHeading(entity.entity))
            FreezeEntityPosition(cache.ped, true)
        end
    }
})

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    SpawnObject()
end)

function SpawnObject()
    for _, v in ipairs(Crafting.PositionCrafting) do
        local heading = 0.0 + v.heading
        local createCrafting = CreateObject("gr_prop_gr_bench_02b", v.coords.x, v.coords.y, v.coords.z, false, true, false)

        if createCrafting then
            SetEntityHeading(createCrafting, heading)
            SetEntityCollision(createCrafting, true, true)
            PlaceObjectOnGroundProperly(createCrafting)
            table.insert(objectPosition, createCrafting)
        else
            debug('Error during the creation of the crafting object.')
        end
    end
end

AddEventHandler("onResourceStop", function(re)
    if re == GetCurrentResourceName() then
        for _, v in pairs(objectPosition) do
            debug(v)
            DeleteEntity(v)
        end
    end
end)

function OpenCrafting(coords, heading)
    local options = {}
    local PlayerJob = GetJobPlayer()
    local value = false

    debug(PlayerJob)

    for k, v in pairs(Crafting.Weapon) do
        debug(v)

        if v.requiredJob then
            for _, data in pairs(v.allowlistJob) do
                debug('For Job ' .. data)

                if data == PlayerJob then
                    debug('Check')
                    Wait(50)
                    local option = {
                        label = v.weaponName,
                        args = { value = k, code = v.weaponCode },
                        close = true,
                        icon = "fa-solid fa-gun",
                        iconColor = '#0061A2'
                    }

                    table.insert(options, option)
                    value = true
                end
            end
        else
            debug(v)
            Wait(50)
            local option = {
                label = v.weaponName,
                args = { value = k, code = v.weaponCode },
                close = true,
                icon = "fa-solid fa-gun",
                iconColor = '#5C7CFA'
            }

            table.insert(options, option)
            value = true
        end
    end

    Wait(50)

    if value then
        lib.registerMenu({
            id = 'ApriCrafting',
            title = lang.menu_title,
            position = 'top-left',
            options = options,
            onClose = function()
                CamOFF()
            end,
        }, function(selected, scrollIndex, args)
            local value = args.value
            local code = args.code
            local hash = GetHashKey(value)

            if selected then
                CreaArma(hash, coords, heading, code, value)
            end
        end)
        lib.showMenu('ApriCrafting')
    elseif not value then
        Wait(1000)
        CamOFF()
    end
end


local function GetIntFromBlob(b, s, o)
    local r = 0
    for i = 1, s, 1 do
        r = r | (string.byte(b, o + i) << (i - 1) * 8)
    end
    return r
end

function GetWeaponStats(weaponHash, none)
    local blob = '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0'
    local retval = Citizen.InvokeNative(0xD92C739EE34C9EBA, weaponHash, blob, Citizen.ReturnResultAnyway())
    local hudDamage = GetIntFromBlob(blob, 8, 0)
    local hudSpeed = GetIntFromBlob(blob, 8, 8)
    local hudCapacity = GetIntFromBlob(blob, 8, 16)
    local hudAccuracy = GetIntFromBlob(blob, 8, 24)
    local hudRange = GetIntFromBlob(blob, 8, 32)
    return retval, hudDamage, hudSpeed, hudCapacity, hudAccuracy, hudRange
end

function CreaArma(hash, coords, d, code, value)
    local modelHash = hash
    inCam = true
    DeleteObject(obj)
    local s = d - 180
    local heading = s
    obj = CreateObject(modelHash, coords.x, coords.y, coords.z + 1.1, true, false, true)
    SetEntityHeading(obj, heading)
    OpenMenuWeapon(code, value)
    Citizen.CreateThread(function()
        while inCam do
            Wait(0)
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 30, true) -- D
            InfoCrafting()
            if IsControlPressed(0, 9) then    -- Right
                heading = heading + 5
                SetEntityHeading(obj, heading)
            elseif IsControlPressed(0, 63) then -- Left
                heading = heading - 5
                SetEntityHeading(obj, heading)
            end
        end
    end)
end

function OpenMenuWeapon(hash, value)
    local options = {
        { label = lang.menu2_options_1, close = true, icon = "fa-solid fa-hammer"},
        { label = lang.menu2_options_2, close = true, icon = "fa-solid fa-circle-info"},
    }
    Wait(100)
    lib.registerMenu({
        id = 'OpenMenuInfo',
        title = lang.menu2_title,
        position = 'top-left',
        options = options,
        onClose = function()
            DeleteObject(obj)
            lib.showMenu('ApriCrafting')
        end,
    }, function(selected, scrollIndex, args)
        if selected == 1 then
            OpenMenuCraft(hash, value)
        elseif selected == 2 then
            OpenMenuInfo(hash, value)
        end
    end)
    lib.showMenu('OpenMenuInfo')
end

function OpenMenuCraft(hash, value)
    local options = {}
    local craftingInfo = {}
    for k, v in pairs(Crafting.Weapon) do
        if k == value then
            weaponName = v.weaponCode
            xp = v.requiredXp
            options[#options + 1] = {
                label = lang.menu3_options_3.." "..xp,
                close = false,
                icon = "fa-solid fa-arrow-up-wide-short"
            }
            for j, l in pairs(v.ItemRequired) do
                debug("Item Name: " .. l.itemName .. " Item Quantity: " .. l.quantity)
                craftingInfo[#craftingInfo + 1] = {
                    itemName = l.itemName,
                    quantity = l.quantity,
                }
                options[#options + 1] = {
                    label = lang.menu3_options_1.. l.itemName .. " x " .. l.quantity,
                    close = false,
                    icon = "fa-solid fa-clipboard"
                }
            end
        end
    end
    options[#options + 1] = {
        label = lang.menu3_options_2,
        close = true,
        args = { craftingInfo = craftingInfo },
        icon = "fa-solid fa-hammer"
    }
    Wait(50)
    lib.registerMenu({
        id = 'OpenMenuRealCraft',
        title = lang.menu3_title,
        position = 'top-left',
        options = options,
        onClose = function()
            OpenMenuWeapon(hash, value)
        end,
    }, function(selected, scrollIndex, args)
        local totalOptions = #options
        local item = args.craftingInfo
        local data = lib.callback.await('px_crafting:getItemCount', false, args.craftingInfo)
        if selected == totalOptions then
            debug('Start check item and xp...')
            debug(data)
            if data.value then
                if Crafting.XpSystem then
                    if data.xp >= xp then
                        debug('Start Crafting')
                        if lib.progressBar({
                                duration = 2000,
                                label = 'Creating',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    car = true,
                                },
                                anim = {
                                    dict = 'mini@repair',
                                    clip = 'fixing_a_ped'
                                },
                            }) then
                                CamOFF()
                                TriggerServerEvent('px_crafting:removeItem', item, weaponName)
                            end
                    else
                        debug('You don\'t have enough experience points')
                        lib.notify({
                            title = lang.notify_enough_xp,
                            description = '',
                            type = 'error',
                            position = 'top-center'
                        })
                        CamOFF()
                    end
                else
                    debug('Start Crafting')
                    if lib.progressBar({
                            duration = 2000,
                            label = 'Creating',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                            },
                            anim = {
                                dict = 'mini@repair',
                                clip = 'fixing_a_ped'
                            },
                        }) then
                            CamOFF()
                            TriggerServerEvent('px_crafting:removeItem', item, weaponName)
                        end
                end
            else
                CamOFF()
            end
        end
    end)
    lib.showMenu('OpenMenuRealCraft')
end


function OpenMenuInfo(hash, value)
    local job = GetJobPlayer()
    debug("Player Job " .. job)
    local options = {}
    local _, hudDamage, hudSpeed, hudCapacity, hudAccuracy, hudRange = GetWeaponStats(GetHashKey(hash))
    debug(_, hudDamage, hudSpeed, hudCapacity, hudAccuracy, hudRange)
    options = {
        { label = lang.menu4_options_1..' (' .. hudDamage .. '%)',     progress = hudDamage,   colorScheme = '#0061A2', close = false },
        { label =lang.menu4_options_2..' (' .. hudSpeed .. '%)',       progress = hudSpeed,    colorScheme = '#0061A2', close = false },
        { label = lang.menu4_options_3..' (' .. hudCapacity .. '%)', progress = hudCapacity, colorScheme = '#0061A2', close = false },
        { label = lang.menu4_options_4..' (' .. hudAccuracy .. '%)', progress = hudAccuracy, colorScheme = '#0061A2', close = false },
        { label = lang.menu4_options_5..' (' .. hudRange .. '%)',       progress = hudRange,    colorScheme = '#0061A2', close = false }
    }
    Wait(100)
    lib.registerMenu({
        id = 'OpenMenuInfo',
        title = lang.menu4_title,
        position = 'top-left',
        options = options,
        onClose = function()
            OpenMenuWeapon(hash, value)
        end,
    }, function(selected, scrollIndex, args)
    end)
    lib.showMenu('OpenMenuInfo')
end

function CamON(obj, coordsArma, heading)
    local coords = GetOffsetFromEntityInWorldCoords(obj, 0, -0.75, 0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 1.2)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(obj))
        OpenCrafting(coordsArma, heading)
    else
        CamOFF()
        Wait(500)
        CamON()
    end
end


function InfoCrafting()
    Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
    while not HasScaleformMovieLoaded(Scale) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(Scale, "CLEAR_ALL");
    EndScaleformMovieMethod();

    --Destra
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(0);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_RIGHT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate right");
    EndScaleformMovieMethod();

    --Sinistra
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(1);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_LEFT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate Left");
    EndScaleformMovieMethod();

    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(2);
    PushScaleformMovieMethodParameterString("~INPUT_CELLPHONE_CANCEL~");
    PushScaleformMovieMethodParameterString("Exit");
    EndScaleformMovieMethod();


    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS");
    ScaleformMovieMethodAddParamInt(0);
    EndScaleformMovieMethod();

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0);
end

function CamOFF()
    lib.hideMenu('ApriCrafting')
    FreezeEntityPosition(cache.ped, false)
    DeleteObject(obj)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    SetLocalPlayerAsGhost(false)
    inCam = false
end

local confirmed
local heading

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function DrawPropAxes(prop)
    local propForward, propRight, propUp, propCoords = GetEntityMatrix(prop)

    local propXAxisEnd = propCoords + propRight * 1.0
    local propYAxisEnd = propCoords + propForward * 1.0
    local propZAxisEnd = propCoords + propUp * 1.0

    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propXAxisEnd.x, propXAxisEnd.y, propXAxisEnd.z, 255, 0, 0,
        255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propYAxisEnd.x, propYAxisEnd.y, propYAxisEnd.z, 0, 255, 0,
        255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propZAxisEnd.x, propZAxisEnd.y, propZAxisEnd.z, 0, 0, 255,
        255)
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination
        .x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

local function placeProp(prop)
    prop = joaat(prop)
    heading = 0.0
    confirmed = false

    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Wait(0)
    end

    local hit, coords

    while not hit do
        hit, coords = RayCastGamePlayCamera(10.0)
        Wait(0)
    end

    local propObject = CreateObject(prop, coords.x, coords.y, coords.z, true, false, true)

    CreateThread(function()
        while not confirmed do
            hit, coords, entity = RayCastGamePlayCamera(10.0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            SetEntityCoordsNoOffset(propObject, coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(propObject, true)
            SetEntityCollision(propObject, false, false)
            SetEntityAlpha(propObject, 100, false)
            debug(heading)
            DrawPropAxes(propObject)
            Wait(0)

            if IsControlPressed(0, 15) then     -- Left
                heading = heading + 5.0
            elseif IsControlPressed(0, 14) then -- Right
                heading = heading - 5.0
            end

            if IsControlJustPressed(0, 177) then
                DeleteObject(propObject)
                confirmed = true
            end

            if heading > 360.0 then
                heading = 0.0
            elseif heading < 0.0 then
                heading = 360.0
            end

            SetEntityHeading(propObject, heading)

            if IsControlJustPressed(0, 38) then -- "E"
                confirmed = true
                lib.setClipboard('{coords = vector3('..coords.x..", "..coords.y..", "..coords.z..'), heading ='..heading..'}')
                DeleteObject(propObject)
                lib.notify({
                    title = lang.notify_copy_coords,
                    description = '',
                    type = 'success',
                    position = 'top-center'
                })
            end
        end
    end)
end

RegisterCommand("createCrafting", function()
    placeProp('gr_prop_gr_bench_02b')
end)
