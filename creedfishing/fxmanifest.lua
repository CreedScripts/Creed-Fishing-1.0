fx_version 'cerulean'
game 'gta5'
lua54 'yes' 
author 'Creed Scripts'
description 'Creed Scripts advanced Fishing!'
version '1.0'


shared_scripts { 'config.lua', '@ox_lib/init.lua' }


client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/treasure.png'
}




