fx_version 'cerulean'
game 'gta5'

author 'Virginia FivePD Development'
description 'Modern RP Chat System'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

shared_script 'config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}