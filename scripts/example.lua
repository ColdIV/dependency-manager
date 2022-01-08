local obj = {}

obj.requires = {
    "examplePrint"
}

local examplePrint = require("examplePrint")

function obj:test {
    examplePrint:printRandomNumber()
}

return obj