-- ──────────────────────────────────────────────────────────────────────────────
--  W2F-ID  |  client/main.lua
-- ──────────────────────────────────────────────────────────────────────────────

local Framework  = nil
local QBCore     = nil
local ESX        = nil

-- ─── Framework bootstrap ─────────────────────────────────────────────────────

local function DetectFramework()
    local cfg = Config.Framework

    if cfg == 'qbx' or (cfg == 'auto' and GetResourceState('qbx_core') == 'started') then
        Framework = 'qbx'
        QBCore    = exports['qbx_core']:GetCoreObject()

    elseif cfg == 'qbcore' or (cfg == 'auto' and GetResourceState('qb-core') == 'started') then
        Framework = 'qbcore'
        QBCore    = exports['qb-core']:GetCoreObject()

    elseif cfg == 'esx' or (cfg == 'auto' and GetResourceState('es_extended') == 'started') then
        Framework = 'esx'
        if GetResourceState('es_extended') == 'started' then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            -- Modern ESX (1.9+) also exposes via export
            if not ESX then
                ESX = exports['es_extended']:getSharedObject()
            end
        end
    end
end

AddEventHandler('onClientResourceStart', function(res)
    if res == GetCurrentResourceName() then
        DetectFramework()
    end
end)

DetectFramework()

-- ─── NUI helper ───────────────────────────────────────────────────────────────

local function ShowCard(cardType, data)
    local themeMap = { id = 'id', driver = 'driver', weapon = 'weapon' }
    local labelMap = {
        id     = 'IDENTIFICATION CARD',
        driver = 'DRIVER LICENSE',
        weapon = 'WEAPON PERMIT',
    }

    SendNUIMessage({
        action   = 'showCard',
        theme    = themeMap[cardType] or 'id',
        state    = Config.State,
        docLabel = labelMap[cardType] or 'IDENTIFICATION CARD',
        ttl      = Config.TTL,
        max      = Config.MaxCards,

        firstname   = data.firstname   or '',
        lastname    = data.lastname    or '',
        dob         = data.dob         or '',
        sex         = data.sex         or '',
        nationality = data.nationality or 'San Andreas',
        cid         = data.cid         or '',
        iss         = data.iss         or os.date('%m/%d/%Y'),
        exp         = data.exp         or '',
        address     = data.address     or '',
        class       = data.class       or '',
        photo       = data.photo       or '',
    })
end

-- ─── Receive card data from server ────────────────────────────────────────────

RegisterNetEvent('w2f-id:showCard', function(cardType, data)
    ShowCard(cardType, data)
end)

-- ─── Commands (debug / admin) ─────────────────────────────────────────────────

if Config.Commands.showId then
    RegisterCommand(Config.Commands.showId, function()
        TriggerServerEvent('w2f-id:requestCard', 'id')
    end, false)
end

if Config.Commands.showLicense then
    RegisterCommand(Config.Commands.showLicense, function()
        TriggerServerEvent('w2f-id:requestCard', 'driver')
    end, false)
end

if Config.Commands.showWeapon then
    RegisterCommand(Config.Commands.showWeapon, function()
        TriggerServerEvent('w2f-id:requestCard', 'weapon')
    end, false)
end

-- ─── NUI callbacks ────────────────────────────────────────────────────────────

RegisterNUICallback('ready', function(_, cb)
    cb('ok')
end)
