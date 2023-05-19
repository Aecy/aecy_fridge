fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vsrp-drinktogether'
version '1.0.0'
description 'Vision RP - Drink Together'
author 'Aecy'


ui_page 'nui/index.html'

shared_script 'config.lua'

client_script 'client/client.lua'
server_script 'server/server.lua'

files {
	'nui/index.html',
	'nui/style.css',
	'nui/app.js',
	'nui/images/*.png'
}