-- ──────────────────────────────────────────────────────────────────────────────
--  W2F-ID  |  server/main.lua
-- ──────────────────────────────────────────────────────────────────────────────

local Framework = nil
local QBCore    = nil
local ESX       = nil

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
        ESX       = exports['es_extended']:getSharedObject()
    end
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        Wait(100) -- brief yield so framework resources finish their own start
        DetectFramework()
        RegisterItems()
    end
end)

-- ─── Player data extraction ───────────────────────────────────────────────────

local function FormatDOB(raw)
    if not raw or raw == '' then return '' end
    -- QBCore stores as YYYY-MM-DD; convert to MM/DD/YYYY
    local y, m, d = tostring(raw):match('^(%d%d%d%d)-(%d%d)-(%d%d)')
    if y then return ('%s/%s/%s'):format(m, d, y) end
    return tostring(raw)
end

local function GetPlayerData(source)
    if Framework == 'qbx' or Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return nil end

        local ci  = Player.PlayerData.charinfo or {}
        local sex = ci.gender
        if type(sex) == 'number' then
            sex = sex == 0 and 'M' or 'F'
        else
            sex = tostring(sex or 'M'):upper():sub(1,1)
        end

        return {
            firstname   = ci.firstname   or 'Unknown',
            lastname    = ci.lastname    or '',
            dob         = FormatDOB(ci.birthdate),
            sex         = sex,
            nationality = ci.nationality or 'San Andreas',
            cid         = Player.PlayerData.citizenid or tostring(source),
            address     = (ci.street or '') ~= '' and ci.street or (ci.location or ''),
        }

    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return nil end

        local dobKey = (Config.ESX and Config.ESX.dobKey)    or 'dateofbirth'
        local dobFb  = (Config.ESX and Config.ESX.dobFallback) or 'birthdate'
        local dob    = xPlayer.get(dobKey)
        if not dob or dob == '' then dob = xPlayer.get(dobFb) end

        local sex = xPlayer.get('sex') or 'm'
        sex = tostring(sex):upper():sub(1,1)

        -- Build a short citizen-ID style token from the identifier
        local ident = tostring(xPlayer.identifier or source)
        local cid   = ident:match('[^:]+$') or ident
        cid = cid:upper():sub(-8)

        return {
            firstname   = xPlayer.get('firstName')  or xPlayer.variables.firstName  or 'Unknown',
            lastname    = xPlayer.get('lastName')   or xPlayer.variables.lastName   or '',
            dob         = FormatDOB(dob),
            sex         = sex,
            nationality = 'San Andreas',
            cid         = cid,
            address     = '',
        }
    end

    return nil
end

-- ─── Issue / expiry dates ─────────────────────────────────────────────────────

local function Dates(cardType)
    local now  = os.date('*t')
    local iss  = ('%02d/%02d/%04d'):format(now.month, now.day, now.year)
    local yrs  = cardType == 'weapon' and 2 or 4
    local exp  = ('%02d/%04d'):format(now.month, now.year + yrs)
    return iss, exp
end

-- ─── Item → card type map ─────────────────────────────────────────────────────

local ItemCardMap = {}

local function BuildItemMap()
    ItemCardMap = {}
    if Config.Items.id_card        then ItemCardMap[Config.Items.id_card]        = 'id'     end
    if Config.Items.driver_license then ItemCardMap[Config.Items.driver_license] = 'driver' end
    if Config.Items.weapon_permit  then ItemCardMap[Config.Items.weapon_permit]  = 'weapon' end
end

-- ─── Useable-item registration ────────────────────────────────────────────────

local function UseItem(source, cardType)
    local data = GetPlayerData(source)
    if not data then
        print('[w2f-id] Could not retrieve player data for source ' .. tostring(source))
        return
    end
    local iss, exp = Dates(cardType)
    data.iss = iss
    data.exp = exp
    TriggerClientEvent('w2f-id:showCard', source, cardType, data)
end

function RegisterItems()
    BuildItemMap()

    if Framework == 'qbcore' then
        for itemName, cardType in pairs(ItemCardMap) do
            QBCore.Functions.CreateUseableItem(itemName, function(source)
                UseItem(source, cardType)
            end)
        end

    elseif Framework == 'qbx' then
        for itemName, cardType in pairs(ItemCardMap) do
            exports['qbx_core']:RegisterUsableItem(itemName, function(source)
                UseItem(source, cardType)
            end)
        end

    elseif Framework == 'esx' then
        -- ESX requires waiting until it is fully initialised
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
            for itemName, cardType in pairs(ItemCardMap) do
                ESX.RegisterUsableItem(itemName, function(source)
                    UseItem(source, cardType)
                end)
            end
        end)
    end
end

-- ─── Command-triggered card (client calls this via RegisterCommand) ────────────

RegisterNetEvent('w2f-id:requestCard', function(cardType)
    local source = source
    UseItem(source, cardType)
end)
