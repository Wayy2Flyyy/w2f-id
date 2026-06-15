local myId = nil

RegisterNetEvent('permanent-id:receive', function(id)
    myId = id
end)

local function chatNotify(msg, ntype)
    TriggerEvent('chat:addMessage', {
        color = ntype == 'error' and { 200, 0, 0 } or { 0, 200, 100 },
        args = { Config.Locale.chatPrefix, msg },
    })
end

local function resolveSystem()
    local s = Config.Notify.system
    if s ~= 'auto' then return s end
    if GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        return 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    elseif GetResourceState('ox_lib') == 'started' and lib then
        return 'ox_lib'
    end
    return 'chat'
end

local function notify(msg, ntype)
    local sys = resolveSystem()
    if sys == 'qbcore' then
        TriggerEvent('QBCore:Notify', msg, ntype == 'error' and 'error' or (ntype == 'success' and 'success' or 'primary'))
    elseif sys == 'esx' then
        TriggerEvent('esx:showNotification', msg)
    elseif sys == 'ox_lib' and lib and lib.notify then
        lib.notify({ title = Config.Locale.chatPrefix, description = msg, type = ntype or 'inform' })
    elseif sys == 'custom' then
        TriggerEvent('permanent-id:customNotify', msg, ntype)
    else
        chatNotify(msg, ntype)
    end
end

RegisterNetEvent('permanent-id:notify', function(msg, ntype)
    notify(msg, ntype)
end)

local function currentId()
    if myId then return myId end
    if Config.StateBag.enabled then return LocalPlayer.state[Config.StateBag.key] end
    return nil
end

exports('GetMyPermanentId', function()
    return currentId()
end)

exports('FormatId', function(id)
    return PID.FormatId(id)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('permanent-id:request')
end)

local function drawText2D(x, y, text, scale, c)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(c.r, c.g, c.b, c.a)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

local viewerVisible = Config.Viewer.startVisible

CreateThread(function()
    while true do
        local sleep = 500
        if Config.Viewer.enabled and viewerVisible then
            local id = currentId()
            if id then
                sleep = 0
                local v = Config.Viewer
                drawText2D(v.position.x, v.position.y, ('%s  %s'):format(v.label, PID.FormatId(id)), v.scale, v.color)
            end
        end
        Wait(sleep)
    end
end)

if Config.Viewer.enabled then
    RegisterCommand(Config.Viewer.command, function()
        viewerVisible = not viewerVisible
    end, false)

    if Config.Viewer.keybind and Config.Viewer.keybind ~= '' then
        RegisterKeyMapping(Config.Viewer.command, 'Toggle Permanent ID viewer', 'keyboard', Config.Viewer.keybind)
    end
end
