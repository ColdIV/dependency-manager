--@requires exampleNumber@QsN94px9

local obj = {}

local exampleNumber = require("cldv.dpm.libs.exampleNumber")

function obj:printRandomNumber ()
    print ("It works! Random Number: " .. exampleNumber)
end

return obj