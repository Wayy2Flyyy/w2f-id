local DB = Config.Database
local C = DB.columns
local T = DB.table

local function quoteIdent(value)
    assert(type(value) == 'string' and value:match('^[%w_]+$'), ('invalid SQL identifier: %s'):format(tostring(value)))
    return ('`%s`'):format(value)
end

local QT = quoteIdent(T)
local QC = {
    id = quoteIdent(C.id),
    identifier = quoteIdent(C.identifier),
    name = quoteIdent(C.name),
    firstSeen = quoteIdent(C.firstSeen),
    lastSeen = quoteIdent(C.lastSeen),
}

PID.Q = {
    select = ('SELECT %s FROM %s WHERE %s = ? LIMIT 1'):format(QC.id, QT, QC.identifier),
    insert = ('INSERT INTO %s (%s, %s, %s, %s) VALUES (?, ?, NOW(), NOW())'):format(QT, QC.identifier, QC.name, QC.firstSeen, QC.lastSeen),
    touch  = ('UPDATE %s SET %s = ?, %s = NOW() WHERE %s = ?'):format(QT, QC.name, QC.lastSeen, QC.identifier),
    byId   = ('SELECT %s FROM %s WHERE %s = ? LIMIT 1'):format(QC.identifier, QT, QC.id),
    taken  = ('SELECT 1 FROM %s WHERE %s = ? LIMIT 1'):format(QT, QC.id),
    reassign = ('UPDATE %s SET %s = ? WHERE %s = ?'):format(QT, QC.id, QC.id),
    maxId  = ('SELECT MAX(%s) AS m FROM %s'):format(QC.id, QT),
    autoIncrement = ('ALTER TABLE %s AUTO_INCREMENT = %%d'):format(QT),
}

PID.Sql = { quoteIdent = quoteIdent, tableName = QT, columns = QC }

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
        if id and id ~= '' then return id end
    end
    return nil
end

local function selectExisting(identifier)
    local row = MySQL.single.await(PID.Q.select, { identifier })
    if not row then return nil end
    return row[C.id]
end

function PID.Resolve(identifier, name)
    if idByIdentifier[identifier] then return idByIdentifier[identifier], false end

    local id = selectExisting(identifier)
    if id then
        idByIdentifier[identifier] = id
        return id, false
    end

    local ok, insertedId = pcall(MySQL.insert.await, PID.Q.insert, { identifier, name })
    if ok and insertedId then
        idByIdentifier[identifier] = insertedId
        return insertedId, true
    end

    -- Another connection may have created this identifier between SELECT and INSERT.
    id = selectExisting(identifier)
    if id then
        idByIdentifier[identifier] = id
        return id, false
    end

    if not ok then PID.Log('ERROR', ('failed to assign ID for %s: %s'):format(identifier, insertedId)) end
    return nil, false
end

function PID.Get(src)
    src = tonumber(src)
    if not src or src <= 0 then return nil end
    if idBySource[src] then return idBySource[src] end
    local identifier = PID.GetIdentifier(src)
    if not identifier then return nil end
    local id = idByIdentifier[identifier]
    if not id then
        id = selectExisting(identifier)
        if id then idByIdentifier[identifier] = id end
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
