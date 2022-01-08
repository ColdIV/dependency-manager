local obj = {}

obj.requires = {
    "exampleNumber@QsN94px9"
}

local exampleNumber = require("exampleNumber")

function obj:printRandomNumber ()
    print ("It works! Random Number: " .. exampleNumber)
end

return obj