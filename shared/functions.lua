PID = PID or {}

function PID.FormatId(id)
    if type(id) ~= 'number' then return tostring(id) end
    local s = tostring(id)
    if Config.Display.pad then
        local pad = (Config.Display.padLength or 0) - #s
        if pad > 0 then s = string.rep('0', pad) .. s end
    end
    return (Config.Display.prefix or '') .. s
end

function PID.IdentifierTypes()
    local list = { Config.Identifier.primary }
    for _, t in ipairs(Config.Identifier.fallbacks or {}) do
        list[#list + 1] = t
    end
    return list
end
