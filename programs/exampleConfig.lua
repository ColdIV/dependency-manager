local args = {...}

local dpm = require("dpm")

local config = dpm:load("config")


config:init("exampleConfig")
config:handleArgs(args)

if #args == 0 then
    print ("Listing variables in config...")
    config:list()
    
    print ("Adding a = true to config")
    config:add("a", true)
    print ("Adding b = \"123\" to config")
    config:add("b", "123")

    print ("Listing variables in config...")
    config:list()
    
    print ("Setting a to false")
    config:set("a", false)
    print ("Setting b to \"456\"")
    config:set("b", "456")
    
    print ("Adding c = \"34234\" to config")
    config:add("c", "34234")
    
    print ("Listing variables in config...")
    config:list()
end