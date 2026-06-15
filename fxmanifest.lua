fx_version 'cerulean'
game 'gta5'

author 'w2f'
description 'Universal permanent player ID — assigned on first join, kept forever'
version '2.1.0'

shared_scripts {
    -- '@ox_lib/init.lua',   --  only if you set Config.Notify.system = 'ox_lib'
    'config/config.lua',
    'shared/functions.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/ids.lua',
    'server/commands.lua',
    'server/main.lua',
}

dependency 'oxmysql'

lua54 'yes'
