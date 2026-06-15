local DB = Config.Database
local C = DB.columns
local T = DB.table

PID.Q = {
    select = ('SELECT %s FROM %s WHERE %s = ?'):format(C.id, T, C.identifier),
    insert = ('INSERT INTO %s (%s, %s, %s, %s) VALUES (?, ?, NOW(), NOW())'):format(T, C.identifier, C.name, C.firstSeen, C.lastSeen),
    touch  = ('UPDATE %s SET %s = ?, %s = NOW() WHERE %s = ?'):format(T, C.name, C.lastSeen, C.identifier),
    byId   = ('SELECT %s FROM %s WHERE %s = ?'):format(C.identifier, T, C.id),
    taken  = ('SELECT 1 FROM %s WHERE %s = ?'):format(T, C.id),
    reassign = ('UPDATE %s SET %s = ? WHERE %s = ?'):format(T, C.id, C.id),
    maxId  = ('SELECT MAX(%s) AS m FROM %s'):format(C.id, T),
}

local idByIdentifier = {}
local idBySource = {}
local identifierBySource = {}

local function cacheActive(src, identifier, id)
    idBySource[src] = id
    identifierBySource[src] = identifier
    if Config.StateBag.enabled then
        Player(src).state:set(Config.StateBag.key, id, Config.StateBag.replicated)
    end
end

function PID.GetIdentifier(src)
    for _, t in ipairs(PID.IdentifierTypes()) do
        local id = GetPlayerIdentifierByType(src, t)
        if id then return id end
    end
    return nil
end

function PID.Resolve(identifier, name)
    if idByIdentifier[identifier] then return idByIdentifier[identifier], false end
    local row = MySQL.single.await(PID.Q.select, { identifier })
    if row then
        local id = row[C.id]
        idByIdentifier[identifier] = id
        return id, false
    end
    local id = MySQL.insert.await(PID.Q.insert, { identifier, name })
    if id then idByIdentifier[identifier] = id end
    return id, true
end

function PID.Get(src)
    src = tonumber(src)
    if not src or src <= 0 then return nil end
    if idBySource[src] then return idBySource[src] end
    local identifier = PID.GetIdentifier(src)
    if not identifier then return nil end
    local id = idByIdentifier[identifier]
    if not id then
        local row = MySQL.single.await(PID.Q.select, { identifier })
        if row then
            id = row[C.id]
            idByIdentifier[identifier] = id
        end
    end
    if id then cacheActive(src, identifier, id) end
    return id
end

function PID.ApplyNewId(identifier, newId)
    idByIdentifier[identifier] = newId
    for s, lic in pairs(identifierBySource) do
        if lic == identifier then cacheActive(s, identifier, newId) end
    end
end

exports('GetPermanentId', PID.Get)
exports('FormatId', PID.FormatId)

AddEventHandler('playerConnecting', function(name, _, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    local identifier = PID.GetIdentifier(src)
    if not identifier then
        PID.Log('WARN', ('no identifier for %s'):format(name))
        if Config.Assignment.blockOnFailure then return deferrals.done(Config.Locale.noIdentifier) end
        return deferrals.done()
    end

    deferrals.update(Config.Locale.fetching)

    local id, isNew = PID.Resolve(identifier, name)
    if not id then
        if Config.Assignment.blockOnFailure then return deferrals.done(Config.Locale.dbError) end
        return deferrals.done()
    end

    if Config.Assignment.updateNameOnJoin then
        MySQL.update(PID.Q.touch, { name, identifier })
    end

    PID.Hook('onLoad', src, identifier, id)
    if isNew then
        PID.Hook('onAssign', src, identifier, id)
        PID.Log('INFO', ('new ID %s for %s'):format(PID.FormatId(id), name))
        PID.Discord('New Permanent ID', ('**%s**\n%s\n`%s`'):format(name, PID.FormatId(id), identifier))
    else
        PID.Log('DEBUG', ('%s loaded %s'):format(name, PID.FormatId(id)))
    end

    deferrals.done()
end)

AddEventHandler('playerJoining', function()
    PID.Get(source)
end)

AddEventHandler('playerDropped', function()
    local src = source
    idBySource[src] = nil
    identifierBySource[src] = nil
end)

RegisterNetEvent('permanent-id:request', function()
    local src = source
    TriggerClientEvent('permanent-id:receive', src, PID.Get(src))
end)
