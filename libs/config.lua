--@requires tablelength

local tablelength = require("cldv.dpm.libs.tablelength")

local obj = {}

obj.name = "default"
obj.path = "default/"
obj.pathPrefix = "cldv/config/"
obj.configFile = "config.json"
obj.config = {}
obj.types = {}

function obj:convertString(value)
    if type(value) == "table" then
        return textutils.serialiseJSON(value)
    else
        return tostring(value)
    end
end

function obj:convertOriginal(name)
    if self.types[name] == "table" then
        return textutils.unserialiseJSON(self.config[name])
    end
    
    if self.types[name] == "boolean" then
        return self.config[name] == "true"
    end
    
    if self.types[name] == "number" then
        return tonumber(self.config[name])
    end

    -- string or unsupported type
    return self.config[name]
end

function obj:checkType(name, value)
    if not self.types[name] or not self.config[name] then return false end

    if self.types[name] == "table" then
        value = textutils.serialiseJSON(value)
        if value then 
            return true
        else 
            return false
        end
    end

    if self.types[name] == "boolean" then
        if value == "true" or value == "false" then
            return true
        else 
            return false
        end
    end

    if self.types[name] == "number" then
        if tostring(tonumber(value)) == value then
            return true
        else
            return false
        end
    end

    -- assume string
    return true
end

function obj:get(name)
    return self:convertOriginal(name)
end

function obj:clear()
    fs.open(self.path .. self.configFile):close()
end

function obj:save()
    local file = fs.open(self.path .. self.configFile, "w")
    if file then
        local temp = {config = self.config, types = self.types}
        file.write (textutils.serializeJSON(temp))
        file.close()
    end
end

function obj:load()
    local file = fs.open(self.path .. self.configFile, "r")

    if not file then
        self:save()
    else
        local temp = textutils.unserializeJSON(file.readAll()) or {}
        file.close()
        if temp.config and tablelength(temp.config) >= tablelength(self.config) and
           temp.types and tablelength(temp.types) >= tablelength(self.types) then
            self.config = temp.config
            self.types = temp.types
        else self:save() end
    end
end

function obj:add(name, value)
    if not self.config[name] then
        self.types[name] = type(value)
        if type(value) == "table" then
            value = textutils.serialiseJSON(value)
        end
        self.config[name] = value
        self:save()
        return true
    end
    return false
end

function obj:set(name, value)
    if self.config[name] ~= nil then
        if not self:checkType(name, value) then
            return false
        end
        self.config[name] = value
        self:save()
        return true
    else
        return false
    end
end

function obj:list()
    print ("+--------+--------+---------+")
    print ("| ", "name", " | ", "type", " | ", "value", " |")
    print ("+--------+--------+---------+")
    for name, value in pairs(self.config) do
        print (name, " ", self.types[name], " ", value)
    end
end

function obj:handleArgs(args)
    if args[1] ~= "config" then return false end
    if not args[2] then self:list() return true end

    for name, value in pairs(self.config) do
        if args[2] == name then
            if args[3] then
                self:set(args[2], args[3])
            else
                print (self:get(args[2]))
            end
            return true
        end
    end
end

function obj:init(name, path)
    self.name = name
    if path then
        self.path = path
    else
        self.path = self.pathPrefix .. self.name .. "/"
    end
    
    self:load()
end

return obj