Config = {}

Config.Version = '2.1.0'
Config.Debug = false

-- Database --------------------------------------------------------------------
-- Table + columns are fully renameable. The table is auto-created on start.
Config.Database = {
    table = 'user_permanent_ids',
    columns = {
        id         = 'permanent_id',
        identifier = 'identifier',
        name       = 'player_name',
        firstSeen  = 'first_seen',
        lastSeen   = 'last_seen',
    },
}

-- Identity --------------------------------------------------------------------
-- The ID is locked to the first identifier found in this order.
-- license survives name/IP/Steam changes, so it's the safest primary.
Config.Identifier = {
    primary   = 'license',
    fallbacks = { 'license2', 'fivem', 'steam', 'discord' },
}

-- Assignment ------------------------------------------------------------------
Config.Assignment = {
    startId          = 1,     -- first ID ever handed out
    blockOnFailure   = true,  -- kick if identity/DB lookup fails (vs let in with no ID)
    updateNameOnJoin = true,  -- refresh stored name + last_seen each join
}

-- State bag -------------------------------------------------------------------
-- Mirrors the ID so any resource reads it instantly: Player(src).state[key] / LocalPlayer.state[key]
Config.StateBag = {
    enabled    = true,
    key        = 'permanentId',
    replicated = true,
}

-- Display ---------------------------------------------------------------------
-- Controls FormatId(): pad=true,len=4,prefix='#' -> 7 becomes "#0007"
Config.Display = {
    pad       = true,
    padLength = 4,
    prefix    = '#',
}

-- Commands --------------------------------------------------------------------
-- Rename, toggle, or re-permission any command. ace = nil means everyone.
Config.Commands = {
    myId   = { enabled = true, name = 'myid',   ace = nil },
    findId = { enabled = true, name = 'findid', ace = 'command.findid' },
    setId  = { enabled = true, name = 'setid',  ace = 'command.setid' },
}

-- Notifications ---------------------------------------------------------------
-- 'auto'   detects qb-core / qbx_core (QBox) / es_extended and routes to it, else chat
-- 'chat' | 'ox_lib' | 'qbcore' | 'esx' | 'custom'
-- ox_lib needs '@ox_lib/init.lua' added to shared_scripts in fxmanifest.lua.
-- custom fires the client event 'permanent-id:customNotify' (msg, type).
-- Works the same on standalone, QBCore, ESX, and QBox — the ID is keyed to the
-- Rockstar license, so no framework is required.
Config.Notify = {
    system = 'auto',
}

-- On-screen ID viewer ---------------------------------------------------------
-- Toggle with the command OR the keybind (players can rebind it in Settings > Keybinds).
Config.Viewer = {
    enabled      = true,
    command      = 'idview',
    keybind      = 'F7',
    startVisible = false,
    label        = 'ID',
    position     = { x = 0.5, y = 0.95 },
    scale        = 0.45,
    color        = { r = 255, g = 255, b = 255, a = 220 },
}

-- Logging ---------------------------------------------------------------------
Config.Logging = {
    console = true,
    discord = {
        enabled = false,
        webhook = '',
        botName = 'Permanent ID',
        color   = 3447003,
    },
}

-- Hooks -----------------------------------------------------------------------
-- Server-side extension points. Drop your own logic in; errors here are isolated.
Config.Hooks = {
    onLoad     = function(src, identifier, id) end,            -- every successful join
    onAssign   = function(src, identifier, id) end,            -- only the very first time a person gets an ID
    onReassign = function(oldId, newId, identifier) end,       -- after /setid succeeds
}

-- Text ------------------------------------------------------------------------
Config.Locale = {
    chatPrefix   = 'ID',
    fetching     = 'Fetching your permanent ID...',
    noIdentifier = 'Could not verify your identity. Your game license is missing.',
    dbError      = 'Database error while loading your ID. Try again shortly.',
    yourId       = 'Your permanent ID is %s',
    notFound     = 'No permanent ID found for you.',
    sameId       = 'Current and new ID are the same.',
    noSuchId     = 'No player has permanent ID %s.',
    taken        = 'Permanent ID %s is already taken.',
    updated      = 'Permanent ID %s -> %s updated.',
    failed       = 'Update failed, nothing changed.',
    usageSetId   = 'Usage: %s <currentId> <newId>',
    usageFindId  = 'Usage: %s <serverId>',
    lookup       = 'Server %s -> permanent ID %s',
}
