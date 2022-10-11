-- Resource Metadata
fx_version 'cerulean'
games {'gta5'}
author 'HU Gang System'
description 'A simple gang system for rp servers :)'
version '1.0'
lua54 'yes'

dependencies {
    'ox_lib',
	'ox_inventory',
	'es_extended'
}

shared_scripts{
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

files {
    'locales/en.json'
}

client_scripts{
	'config.lua',
	'shared/client_config.lua',
    'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'shared/server_config.lua',
	'server/*.lua'
}