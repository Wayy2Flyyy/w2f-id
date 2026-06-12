-- ──────────────────────────────────────────────────────────────────────────────
--  QBCore / QBX shared item definitions for w2f-id
--
--  INSTALLATION:
--  Add the entries below inside the return { ... } table in:
--    [qb-core]/shared/items.lua   (QBCore)
--    [qbx_core]/data/items.lua    (QBX  — preferred format shown)
--
--  QBX also supports the ox_inventory items.lua format (see items.lua).
-- ──────────────────────────────────────────────────────────────────────────────

-- QBCore format (shared/items.lua):
['id_card'] = {
    name        = 'id_card',
    label       = 'Identification Card',
    weight      = 10,
    type        = 'item',
    image       = 'id_card.png',
    unique      = true,
    useable     = true,
    shouldClose = true,
    combinable  = nil,
    description = 'A government-issued identification card.',
},

['driver_license'] = {
    name        = 'driver_license',
    label       = 'Driver License',
    weight      = 10,
    type        = 'item',
    image       = 'driver_license.png',
    unique      = true,
    useable     = true,
    shouldClose = true,
    combinable  = nil,
    description = 'A valid San Andreas driver license.',
},

['weapon_permit'] = {
    name        = 'weapon_permit',
    label       = 'Weapon Permit',
    weight      = 10,
    type        = 'item',
    image       = 'weapon_permit.png',
    unique      = true,
    useable     = true,
    shouldClose = true,
    combinable  = nil,
    description = 'A concealed carry weapon permit (CCW).',
},
