--@requires tablelength

local tablelength = require("dpm.libs.tablelength")

local obj = {}

obj.name = "default"
obj.path = "default/"
obj.configFile = "config.json"
obj.config = {}

function obj:get(name)
    return self.config[name]
end

function obj:clear()
    fs.open(self.path .. self.configFile):close()
end

function obj:save()
    local file = fs.open(self.path .. self.configFile, "w")
    file.write (textutils.serializeJSON(self.config))
    file.close()
end

function obj:load()
    local file = fs.open(self.path .. self.configFile, "r")

    if not file then
        self:save()
    else
        local temp = textutils.unserializeJSON(file.readAll()) or {}
        file.close()
        if tablelength(temp) >= tablelength(self.config) then
            self.config = temp
        else self:save() end
    end
end

function obj:add(name, value)
    if not self.config[name] then
        self.config[name] = value
        self:save()
        return true
    end
    return false
end

function obj:set(name, value)
    if self.config[name] ~= nil then
        self.config[name] = value
        self:save()
        return true
    else
        return false
    end
end

function obj:list()
    for name, value in pairs(self.config) do
        print (name, " ", value)
    end
end

function obj:handleArgs(args)
    if args[1] ~= "config" then return false end
    if not args[2] then self:list() return true end

    for name, value in pairs(self.config) do
        if args[2] == name then
            if args[3] then
                local value = args[3]
                if args[3] == "true" then value = true
                elseif args[3] == "false" then value = false end
                self:set(args[2], value)
            else
                print (self:get(args[2]))
            end
        end
    end
end

function obj:init(name, path)
    self.name = name
    if path then
        self.path = path
    else
        self.path = self.name .. "/"
    end
    
    self:load()
end

return obj