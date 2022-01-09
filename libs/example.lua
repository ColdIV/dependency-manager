--@requires examplePrint

local obj = {}

local examplePrint = require("dpm.libs.examplePrint")

function obj:test()
    examplePrint:printRandomNumber()
end

return obj