Config = {}

-- ──────────────────────────────────────────────────────────────────────────────
--  Framework
--  'auto'    → auto-detect (recommended)
--  'qbx'     → qbx_core
--  'qbcore'  → qb-core
--  'esx'     → es_extended
-- ──────────────────────────────────────────────────────────────────────────────
Config.Framework = 'auto'

-- ──────────────────────────────────────────────────────────────────────────────
--  Items
--  These names must match the item names registered in your inventory system.
--  Set any to false to disable that card type entirely.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Items = {
    id_card        = 'id_card',
    driver_license = 'driver_license',
    weapon_permit  = 'weapon_permit',
}

-- ──────────────────────────────────────────────────────────────────────────────
--  Display
-- ──────────────────────────────────────────────────────────────────────────────
Config.TTL      = 6000  -- milliseconds before the card auto-dismisses
Config.MaxCards = 3     -- maximum cards visible at once

-- ──────────────────────────────────────────────────────────────────────────────
--  State / jurisdiction text shown on every card
-- ──────────────────────────────────────────────────────────────────────────────
Config.State = 'SAN ANDREAS'

-- ──────────────────────────────────────────────────────────────────────────────
--  Commands  (set to false to disable)
--  These let admins inspect their own card without needing the item in hand.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Commands = {
    showId      = 'showid',
    showLicense = 'showlicense',
    showWeapon  = 'showweapon',
}

-- ──────────────────────────────────────────────────────────────────────────────
--  ESX-specific  (only used when Framework == 'esx' or auto-detected as ESX)
-- ──────────────────────────────────────────────────────────────────────────────
Config.ESX = {
    -- Some ESX builds expose dateofbirth / birthdate under different keys.
    -- Try 'dateofbirth' first; fall back to the value below if blank.
    dobKey     = 'dateofbirth',
    dobFallback = 'birthdate',
}
