-- pastebin run FuQ3WvPs wbPXakgy advancedMining
local args = {...}

-- CONFIG -- EDIT BELOW

local fuelTable = {
	"coal",
    "charcoal"
}
local lootTable = {
	"coal",
    "coal_ore",
    "diamond",
    "diamond_ore",
    "iron_ore",
    "gold_ore",
    "lapis_lazuli",
    "lapis_lazuli_ore",
    "emerald"
}
-- NOTE: The turtle will send notifications if it finds loot in this table
-- the turtle wont look for these blocks, if you want to farm them add them to the loot table
local rareLootTable = {
    "coal",
    "coal_ore",
    "diamond",
    "diamond_ore",
    "gold_ore",
    "lapis_lazuli",
    "lapis_lazuli_ore",
    "emerald",
    "emerald_ore"
}
local blockTable = {
	"cobblestone",
    "dirt",
    "stone",
    "diorite",
    "andesite",
    "granite",
    "redstone"
}
local lightTable = {
	"torch"
}
local sideTrackMaxLength = 32
local placeTorchAt = 8
local notifications = true
local ignoreErrors = {} -- just add the error nr to the table
local DEBUG = false

-- END CONFIG / START CODE -- DO NOT EDIT BELOW

local version = "v1.0"
local turtleName = os.getComputerLabel()
local startupMessage = [[
---------------------------------
- advancedMining ]] .. version .. [[           -
- by ColdIV                     -
- pastebin.com/wbPXakgy         -
---------------------------------
]]
local consolePrefix = "[aM " .. version .. "] "

local T = turtle
local chatBox = peripheral.wrap("right")

local itemPrefix = "minecraft:"
local fuelSlots = {}
local lootSlots = {}
local blockSlots = {}
local lightSlots = {}

local wayBack = 0 -- should hold the amount of fuel needed for the way back to the starting point
local onMainTrack = true
local mainTrackLength = 0 -- will increase over time
local lastSideTrack = 0 -- distance since last side track
local sideTrackLength = 0 -- out of sideTrackMaxLength

local errors = {}
local errorCodes = {
    ["0"] = "Not enough fuel.",
    ["1"] = "Not enough building blocks.",
    ["2"] = "Not enough light sources."
}

function hasError ()
    if DEBUG then print ("start hasError") end
    
	if #errors == 0 then 
        if DEBUG then print ("end hasError (no error)") end
        
        return false
    end
    
    local skip = false
    for nr = 1, #errors do
        -- check if error should be ignored
        for i = 1, #ignoreErrors do
            if errors[nr] == ignoreErrors[i] then
                skip = true
                break
            end
        end
        -- skip error if it is in ignore list, otherwise print it
    	if not skip then 
            if notifications and chatBox then
                chatBox.sendMessage(consolePrefix .. "(" .. turtleName .. ")ERROR: " .. errorCodes[tostring(errors[nr])])
            end
            error(errorCodes[tostring(errors[nr])])
        end
        skip = false
    end
    
    if DEBUG then print ("end hasError (error)") end
    
    return true
end

function selectBuildingBlock (selectBlock)
    if DEBUG then print ("start selectBuildingBlock") end
    
    if selectBlock == nil then selectBlock = true end
    
    blockSlots = {}
    
    for slot = 1, 16 do
        local itemDetails = T.getItemDetail(slot)
        if itemDetails then
            for i = 1, #blockTable do
                if itemDetails.name == itemPrefix .. blockTable[i] then
                    table.insert(blockSlots, slot)
                end
            end
        end
    end

    if #blockSlots == 0 then
        table.insert(errors, 1)
        
        if DEBUG then print ("end selectBuildingBlock") end
        
        return false
    end
    
    if selectBlock then T.select(blockSlots[1]) end
    
    if DEBUG then print ("end selectBuildingBlock") end
    
    return true
end

function selectLightBlock (selectBlock)
    if DEBUG then print ("start selectLightBlock") end
    
    if selectBlock == nil then selectBlock = true end
    
    lightSlots = {}
    
    for slot = 1, 16 do
        local itemDetails = T.getItemDetail(slot)
        if itemDetails then
            for i = 1, #lightTable do
                if itemDetails.name == itemPrefix .. lightTable[i] then
                    table.insert(lightSlots, slot)
                end
            end
        end
    end
    
    if #lightSlots == 0 then
        table.insert(errors, 2)
        
        if DEBUG then print ("end selectLightBlock") end
        
        return false
    end
    
    if selectBlock then T.select(lightSlots[1]) end
    
    if DEBUG then print ("end selectLightBlock") end
    
    return true
end

function checkSlots ()
    if DEBUG then print ("start checkSlots") end
    
    -- checks which slots are being used and for what
    local itemDetails
    fuelSlots = {}
    lootSlots = {}
    
	for slot = 1, 16 do
        local itemDetails = T.getItemDetail(slot)
        if itemDetails then
            for i = 1, #fuelTable do
                if itemDetails.name == (itemPrefix .. fuelTable[i]) then
                    table.insert(fuelSlots, slot)
                end
            end
            
            for i = 1, #lootTable do
                if itemDetails.name == itemPrefix .. lootTable[i] then
                    table.insert(lootSlots, slot)
                end
            end    
        end
    end

    if #fuelSlots == 0 and T.getFuelLevel() - wayBack <= 0 then
        table.insert(errors, 0)
    end
    
    selectBuildingBlock()
    
    selectLightBlock(false)
    
    if DEBUG then print ("end checkSlots") end
    
    return true
end

function refuel ()
    if DEBUG then print ("start refuel") end
    
    print (consolePrefix .. "Refuelling")
	if #fuelSlots == 0 and T.getFuelLevel() - wayBack <= 0 then
    	table.insert(errors, 0)
        
        if DEBUG then print ("end refuel (error)") end
        
        return false
    end
    
    if not #fuelSlots == 0 then
        local currentSlot = T.getSelectedSlot()
        T.select(fuelSlots[1])
        T.refuel()
        T.select(currentSlot)
    end
    
    if DEBUG then print ("end refuel") end
    
    return true
end

function place (dir)
    if DEBUG then print ("start place") end

    dir = dir or ""
    local placeFunc = T.place
    local blockFunc = selectBuildingBlock
    if dir == "up" then
        placeFunc = T.placeUp
    elseif dir == "down" then
        placeFunc = T.placeDown
    elseif dir == "torch" then
        placeFunc = T.placeUp
        blockFunc = selectLightBlock
    end
    
    -- if not placeFunc() then
    blockFunc()
    placeFunc()
    -- end
    
    if DEBUG then print ("end place") end
end

function dig (dir)
    if DEBUG then print ("start dig") end
    
    dir = dir or ""
    local has_block, data = T.inspect()
    local digFunc = T.dig
    
    if dir == "up" then
        digFunc = T.digUp
        has_block, data = T.inspectUp()
    elseif dir == "down" then
        digFunc = T.digDown
        has_block, data = T.inspectDown()
    end
    
    if has_block then
        -- check if block is in rare loot table
        if notifications and chatBox then
            for item = 1, #rareLootTable do
                if itemPrefix .. rareLootTable[item] == data.name then
                    chatBox.sendMessage(consolePrefix .. turtleName .. " found rare item: " .. rareLootTable[item])
                end
            end
        end
        -- dig
        digFunc()
    end
    
    if DEBUG then print ("end dig") end
end

function placeLight ()
    if DEBUG then print ("start placeLight") end
    
    local currentSlot = T.getSelectedSlot()
    place("torch")
    T.select(currentSlot)
    
    if DEBUG then print ("end placeLight") end
end

function mining (placeTorch)
    if DEBUG then print ("start mining") end
    
    print (consolePrefix .. "Moving forward")
     -- move forward, if not possible -> dig
    while not T.forward() do
        dig()
    end
    
    -- build floor
    place("down")
    
    -- build lower left wall
    T.turnLeft()
    place()
    
    -- move up
    while not T.up() do
        dig("up")
    end
    
    -- build ceiling
    place("up")
    
    -- build upper left wall
    place()
    
    -- build upper right wall
    turnAround()
    place()
    
    -- move down
    T.down()
    
    -- build lower right wall
    place()
    
    -- place light
    if placeTorch then
        print (consolePrefix .. "Placing light")
        placeLight()
    end
    
    -- turn back to path
    T.turnLeft()
    
    if onMainTrack then 
        mainTrackLength = mainTrackLength + 1
        lastSideTrack = lastSideTrack + 1
    else sideTrackLength = sideTrackLength + 1 end
    
    if DEBUG then print ("end mining") end
end

function turnAround ()
    if DEBUG then print ("start turnAround") end
    
    T.turnRight()
    T.turnRight()
    
    if DEBUG then print ("end turnAround") end
end

function move ()
    if DEBUG then print ("start move") end
    
    if onMainTrack and lastSideTrack >= 3 then
        print (consolePrefix .. "Leaving main track")
        onMainTrack = false
        lastSideTrack = 0
        T.turnRight()
    elseif not onMainTrack and sideTrackLength >= sideTrackMaxLength then
        print (consolePrefix .. "Going back to main track")
        turnAround()
        sideTrackLength = 0
        for step = 1, sideTrackMaxLength do
            print (consolePrefix .. tostring(step) .. " of " .. tostring(sideTrackMaxLength))
            T.forward()
        end
        T.turnRight()
        onMainTrack = true
    end
    
    if DEBUG then print ("end move") end
end

function returnHome ()
    if DEBUG then print ("start returnHome") end
    
    print (consolePrefix .. "Returning to starting point")
    
    if onMainTrack then
        print (consolePrefix .. "On main track")
        turnAround()
        
        for i = 1, mainTrackLength do
            T.forward()
        end
    else
        print (consolePrefix .. "On side track")
        turnAround()
        
        for i = 1, sideTrackLength do
            T.forward()
        end
        
        T.turnRight()
        onMainTrack = true
        returnHome()
        return
    end
    
    print (consolePrefix .. "I am home! Quitting.")
    
    if DEBUG then print ("end returnHome") end
end

function main ()
    if DEBUG then print ("start main") end
    
    print (startupMessage)
    
    if chatBox then print (consolePrefix .. "Chatbox detected") end
    
    local continue = true
    
    -- startup
    continue = checkSlots()
    continue = refuel()
    continue = selectBuildingBlock()
    continue = not hasError()
    
    -- program loop
    print (consolePrefix .. "Start mining")
    while continue do
        if T.getFuelLevel() == 0 then
            refuel()
        end
        
        move()
        mining((not onMainTrack and (((sideTrackLength + 1) % placeTorchAt == 0) or (sideTrackLength + 1) == 1)))
        
        continue = not hasError()
	end
    
    -- an error occured, return turtle to starting point
    returnHome()
    
    if DEBUG then print ("end main") end
end

-- END CODE

if args[1] == "update" then
    if args[2] == "run" then
        shell.run("pastebin", "run", "FuQ3WvPs wbPXakgy advancedMining run")
    else
        shell.run("pastebin", "run", "FuQ3WvPs wbPXakgy advancedMining")
    end 
else
    -- RUN MAIN PROGRAM
    main()
end