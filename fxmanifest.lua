fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'w2f-id'
author      'wayy2flyyy'
description 'W2F ID – Visual ID card system | QBX · QBCore · ESX · ox_inventory'
version     '1.0.0'
repository  'https://github.com/wayy2flyyy/w2f-id'

ui_page 'html/index.html'

files {
    'html/index.html',
}

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}
