local dpm = require("dpm")

local log = dpm:load("log")

local args = {...}
log:init('exampleLog')
log:handleArgs(args)

if #args == 0 then
    log:write('test')
    log:write('test 123')
end