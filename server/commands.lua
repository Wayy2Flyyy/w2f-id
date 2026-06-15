local function gated(src, ace)
    if src == 0 then return true end
    if not ace then return true end
    return IsPlayerAceAllowed(src, ace)
end

local mc = Config.Commands.myId
if mc.enabled then
    RegisterCommand(mc.name, function(src)
        if src == 0 then return print('[permanent-id] console has no permanent ID') end
        local id = PID.Get(src)
        if id then
            PID.NotifyClient(src, Config.Locale.yourId:format(PID.FormatId(id)), 'success')
        else
            PID.NotifyClient(src, Config.Locale.notFound, 'error')
        end
    end, false)
end

local fc = Config.Commands.findId
if fc.enabled then
    RegisterCommand(fc.name, function(src, args)
        if not gated(src, fc.ace) then return end
        local target = tonumber(args[1])
        if not target then return PID.NotifyClient(src, Config.Locale.usageFindId:format(fc.name), 'error') end
        local id = PID.Get(target)
        PID.NotifyClient(src, Config.Locale.lookup:format(target, id and PID.FormatId(id) or '?'), 'inform')
    end, true)
end

local sc = Config.Commands.setId
if sc.enabled then
    RegisterCommand(sc.name, function(src, args)
        if not gated(src, sc.ace) then return end

        local cur = tonumber(args[1])
        local new = tonumber(args[2])
        if not cur or not new or cur <= 0 or new <= 0 then
            return PID.NotifyClient(src, Config.Locale.usageSetId:format(sc.name), 'error')
        end
        if cur == new then return PID.NotifyClient(src, Config.Locale.sameId, 'error') end

        local row = MySQL.single.await(PID.Q.byId, { cur })
        if not row then return PID.NotifyClient(src, Config.Locale.noSuchId:format(cur), 'error') end

        if MySQL.scalar.await(PID.Q.taken, { new }) then
            return PID.NotifyClient(src, Config.Locale.taken:format(new), 'error')
        end

        local affected = MySQL.update.await(PID.Q.reassign, { new, cur })
        if not affected or affected == 0 then
            return PID.NotifyClient(src, Config.Locale.failed, 'error')
        end

        local identifier = row[Config.Database.columns.identifier]
        PID.ApplyNewId(identifier, new)

        local maxId = tonumber((MySQL.single.await(PID.Q.maxId) or {}).m) or 0
        MySQL.update.await(('ALTER TABLE %s AUTO_INCREMENT = %d'):format(Config.Database.table, maxId + 1))

        PID.Hook('onReassign', cur, new, identifier)
        PID.Log('INFO', ('%s reassigned %s -> %s'):format(identifier, PID.FormatId(cur), PID.FormatId(new)))
        PID.NotifyClient(src, Config.Locale.updated:format(PID.FormatId(cur), PID.FormatId(new)), 'success')
    end, true)
end
