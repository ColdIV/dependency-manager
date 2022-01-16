local obj = {}

obj.deviceWidth, _  = term.current().getSize()
obj.prefixColor = "b"
obj.currentColor = "0"
obj.currentBgColor = "f"
obj.colors = {
    ["white"] = "0",
    ["0"] = "0",
    ["orange"] = "1",
    ["1"] = "1",
    ["magenta"] = "2",
    ["2"] = "2",
    ["lightblue"] = "3",
    ["3"] = "3",
    ["yellow"] = "4",
    ["4"] = "4",
    ["lime"] = "5",
    ["5"] = "5",
    ["pink"] = "6",
    ["6"] = "6",
    ["gray"] = "7",
    ["7"] = "7",
    ["lightgray"] = "8",
    ["8"] = "8",
    ["cyan"] = "9",
    ["9"] = "9",
    ["purple"] = "a",
    ["a"] = "a",
    ["blue"] = "b",
    ["b"] = "b",
    ["brown"] = "c",
    ["c"] = "c",
    ["green"] = "d",
    ["d"] = "d",
    ["red"] = "e",
    ["e"] = "e",
    ["black"] = "f",
    ["f"] = "f"
}

function obj:setColor (color)
    if self.colors[color] then
        self.currentColor = self.colors[color]
        return true
    else
        return false
    end
end

function obj:setPrefixColor (color)
    if self.colors[color] then
        self.prefixColor = self.colors[color]
        return true
    else
        return false
    end
end

function obj:setBgColor (color)
    if self.colors[color] then
        self.currentBgColor = self.colors[color]
        return true
    else
        return false
    end
end

function obj:getColor ()
    return self.currentColor
end

function obj:getPrefixColor ()
    return self.prefixColor
end

function obj:getBgColor ()
    return self.bgColor
end

function obj:prefixPrint (prefix, text)    
    local texts = {}
    texts[1] = text
    
    local idx = 1
    local maxLength = self.deviceWidth - #prefix
    
    -- Split text after last space or after maxLength if the string is too long
    -- Note: The prefix has to be smaller than the maxLength.
    while (#texts[idx] > maxLength) do
        local lastSpace = nil
        local offset = 0
        
        lastSpace = string.sub(texts[idx], 1, maxLength):match'^.*() '
        
        if string.find(texts[idx], "\n") then
            local start, _ = string.find(texts[idx], "\n")
            offset = 1
            lastSpace = math.min(lastSpace, start - 1)
        end
        
        if lastSpace == nil then lastSpace = maxLength end
        if idx == 1 then maxLength = self.deviceWidth end
        
        texts[idx + 1] = string.sub(texts[idx], lastSpace + 1 + offset)
        texts[idx] = string.sub(texts[idx], 1, lastSpace)
        idx = idx + 1
    end
    
    -- Setup color strings
    local tColorS = ""
    local bgColorS = ""
    
    for i = 1, #prefix, 1 do 
        tColorS = tColorS .. self.prefixColor
        bgColorS = bgColorS .. self.currentBgColor
    end
    
    -- Print prefix
    term.blit(prefix, tColorS, bgColorS)
    
    -- Print texts
    for i = 1, #texts, 1 do
        tColorS = ""
        bgColorS = ""
        for j = 1, #texts[i], 1 do 
            tColorS = tColorS .. self.currentColor
            bgColorS = bgColorS .. self.currentBgColor
        end 
        
        term.blit(texts[i], tColorS, bgColorS)
        print("")
    end
    
    return #texts
end

function obj:prettyPrint (text)
    return self:prefixPrint("", text)
end

return obj