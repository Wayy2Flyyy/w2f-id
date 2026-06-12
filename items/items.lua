-- ──────────────────────────────────────────────────────────────────────────────
--  ox_inventory item definitions for w2f-id
--
--  INSTALLATION:
--  1. Copy the three item blocks below into:
--       [ox_inventory]/data/items.lua
--     (or your custom items file if you have one)
--
--  2. Copy id_card.png, driver_license.png, weapon_permit.png from
--       [w2f-id]/items/
--     into:
--       [ox_inventory]/web/images/
--     (rename .svg → .png if converting, or use the provided PNGs)
-- ──────────────────────────────────────────────────────────────────────────────

['id_card'] = {
    label  = 'Identification Card',
    weight = 10,
    stack  = false,
    close  = true,
    description = 'A government-issued identification card.',
},

['driver_license'] = {
    label  = 'Driver License',
    weight = 10,
    stack  = false,
    close  = true,
    description = 'A valid San Andreas driver license.',
},

['weapon_permit'] = {
    label  = 'Weapon Permit',
    weight = 10,
    stack  = false,
    close  = true,
    description = 'A concealed carry weapon permit (CCW).',
},
