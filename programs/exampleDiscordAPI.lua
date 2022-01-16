local args = {...}

local dpm = require("dpm")

local config = dpm:load("config")
local discordAPI = dpm:load("discordAPI")

config:init("exampleDiscordAPI")

config:add('API_TOKEN', 'default')
config:add('API_URL', 'default')

config:handleArgs(args)

if #args == 0 then
    -- To set those, run `exampleDiscordAPI config API_TOKEN <token>` and `exampleDiscordAPI config API_URL <url>`
    local API_TOKEN = config:get('API_TOKEN')
    local API_URL = config:get('API_URL')

    discordAPI:init(API_TOKEN, API_URL)
    discordAPI:send("Test message (lib test)")
end