local obj = {}

obj.name = "default"
obj.path = "default/"
obj.pathPrefix = "cldv/logs/"
obj.logFile = "log.txt"

function obj:clear()
    fs.open(self.path .. self.logFile, "w"):close()
end

function obj:write(message)
    if not message then return false end

    local datetime = os.date("[%Y-%m-%d %H:%M:%S] ")
    local file = fs.open(self.path .. self.logFile, "a")
    file.write (datetime .. message .. "\n")
    file.close()

    return true
end

function obj:handleArgs(args)
    if args[1] ~= "log" then return false end
    if args[2] and args[2] == 'clear' then
        self:clear()
    end
end

function obj:init(name, path)
    self.name = name
    if path then
        self.path = path
    else
        self.path = self.pathPrefix .. self.name .. "/"
    end
end

return obj