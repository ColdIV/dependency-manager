local dpm = require("dpm")

local pP = dpm:load("prettyPrint")

pP:prefixPrint("[prefix]: ", "long text with prefix should have a line-break that makes sense instead of just cutting off randomly.")
pP:setColor("red")
pP:prefixPrint("[prefix]: ", "I've now changed the text color, so this text should be red.")
pP:setPrefixColor("white")
pP:prefixPrint("[prefix]: ", "I've now changed the prefix color to white.")
pP:setBgColor("green")
pP:prefixPrint("[prefix]: ", "Now the background is green.")