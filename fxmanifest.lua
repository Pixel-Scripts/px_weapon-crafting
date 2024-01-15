fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Haze'
version '1.0.0'

shared_scripts{
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/*.lua',
    'function/utils.lua'
}

client_scripts{
    'client.lua'
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}