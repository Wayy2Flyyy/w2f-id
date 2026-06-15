function PID.Log(level, msg)
    if not Config.Logging.console then return end
    if level == 'DEBUG' and not Config.Debug then return end
    print(('[permanent-id] [%s] %s'):format(level, msg))
end

function PID.Discord(title, description)
    local d = Config.Logging.discord
    if not d.enabled or d.webhook == '' then return end
    PerformHttpRequest(d.webhook, function() end, 'POST', json.encode({
        username = d.botName,
        embeds = { { title = title, description = description, color = d.color } },
    }), { ['Content-Type'] = 'application/json' })
end

function PID.NotifyClient(src, msg, ntype)
    if src == 0 then
        print('[permanent-id] ' .. msg)
        return
    end
    TriggerClientEvent('permanent-id:notify', src, msg, ntype or 'inform')
end

function PID.Hook(name, ...)
    local fn = Config.Hooks[name]
    if type(fn) ~= 'function' then return end
    local ok, err = pcall(fn, ...)
    if not ok then PID.Log('ERROR', ('hook %s failed: %s'):format(name, err)) end
end
