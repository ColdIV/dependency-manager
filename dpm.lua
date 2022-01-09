---------------------------------------------------------
--- Dependency Manager For CC: Tweaked Scripts ----------
-------------------------------------- by ColdIV --------
---------------------------------------------------------
--[ pastebin run FuQ3WvPs KqhwihZr dpm ]-----------------
---------------------------------------------------------
--[[ Usage [Arguments] ----------------------------------
dpm install <name in git repo>
dpm install <name> <pastebin code>
dpm install <name@pastebin code>
dpm update <name>
dpm update all
dpm remove <name>
dpm remove all
dpm list
dpm config
dpm config <name> <value>
dpm help
dpm help <argument name>
--]]-----------------------------------------------------
--[[ Example [yourScript.lua] ---------------------------
local dpm = require("dpm")
local scriptName = dpm:load("scriptName")
--- or, to install if script cannot be found:
local scriptName = dpm:load("scriptName@pastebinCode")
--]]-----------------------------------------------------
local args = {...}

--- Helper functions
-- src: https://stackoverflow.com/a/2705804/10495683
function tablelength (T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- src: https://tweaked.cc/library/cc.shell.completion.html [modified]
local completion = require "cc.shell.completion"
local complete = completion.build(
    { completion.choice, { "install", "update", "remove", "list", "config", "help" } },
    completion.dir,
    { completion.file, many = true }
)
shell.setCompletionFunction("dpm.lua", complete)
--------------------

local dpm = {}

--- Config
dpm.config = {
    ["verbose"] = false,
    ["logDate"] = true,
    ["writeLogFile"] = true,
    ["logFilePath"] = "log.txt",
    ["code"] = "KqhwihZr",
    ["installScriptCode"] = "FuQ3WvPs",
    ["scriptListPath"] = "scripts.json",
    ["scriptPath"] = "libs/",
    ["gitRepo"] = "ColdIV/dependency-manager/",
    ["gitBranch"] = "master",
    ["rawGit"] = "https://raw.githubusercontent.com/"
}
----------

dpm.dpmPath = "dpm/"
dpm.configFilePath = dpm.dpmPath .. "config.json"
dpm.reservedNames = {
    "all"
}
dpm.scripts = {}
dpm.commandHelp = {
    ["install"] = "install <name in git repo>\tInstalls the given script from the repository\ninstall <name> <code>\tInstalls the given script\ninstall <name@code>\t\tInstalls the given script",
    ["update"] = "update all\t\t\t\t\tUpdates all scripts\nupdate <name>\t\tUpdates script by name",
    ["remove"] = "remove all\t\t\t\t\tRemoves all scripts\nremove <name>\t\tRemoves script by name",
    ["list"] = "list\t\t\tLists all installed scripts",
    ["help"] = "help\t\t\tShows a list of all available arguments",
    ["config"] = "config\t\t\t\t\tShows a list of all available arguments\nconfig name value\t\tSets the value of the variable"
}

function dpm:log (message)
    local datetime = ""
    if self.config.logDate then datetime = os.date("[%Y-%m-%d %H:%M:%S] ") end
    if self.config.verbose then print (datetime .. message) end

    if self.config.writeLogFile then
        local file = fs.open(self.dpmPath .. self.config.logFilePath, "a")
        file.write (datetime .. message .. "\n")
        file.close()
    end
end

function dpm:saveScripts ()
    self:log("Saving scripts...")
    local file = fs.open(self.dpmPath .. self.config.scriptListPath, "w")
    file.write (textutils.serializeJSON(self.scripts))
    file.close()
    self:log("Done")
end

function dpm:getScripts ()
    self:log("Getting scripts...")
    local file = fs.open(self.dpmPath .. self.config.scriptListPath, "r")

    if not file then
        self:log("Error! File does not exist: " .. self.dpmPath .. self.config.scriptListPath)
        self:saveScripts()
    else
        dpm.scripts = textutils.unserializeJSON(file.readAll()) or {}
        self:log("Found " .. tablelength(dpm.scripts) .. " script(s)!")
        self:log("Done")
        file.close()
    end
end

function dpm:getNameCode (argument)
    local separator = string.find(argument, "@")
    if not separator then return nil end
    local name = string.sub(argument, 1, separator - 1)
    local code = string.sub(argument, separator + 1)
    return name, code
end

function dpm:installScript (name, code)
    self:log("Installing script " .. name .. " with code " .. code .. "...")
    for i = 1, #self.reservedNames do
        if name == self.reservedNames[i] then
            self:log("Error! Cannot install script with name \"" .. name .. "\". Name is reserved.")
            return
        end
    end
    shell.run("pastebin", "run", self.config.installScriptCode .. " " .. code .. " " .. self.dpmPath .. self.config.scriptPath .. name)
    self:log("Done")
    
    self.scripts[name] = code
    self:saveScripts()
end

function dpm:getGitURL (name)
    return self.config.rawGit .. self.config.gitRepo .. self.config.gitBranch .. "/" .. self.config.scriptPath .. name .. ".lua"
end

function dpm:installGit (name)
    local url = self:getGitURL(name)
    self:log("Installing script " .. name .. " from " .. url .. "...")
    local request = http.get(url)
    if request then
        local content = request.readAll()
        request.close()

        if content then
            local file = fs.open(self.dpmPath .. self.config.scriptPath .. name, "w")
            file.write(content)
            file.close()
            self:log("Done")
        end
    else
        self:log("Error! Could not read content from: " .. url)
    end
end

function dpm:checkRequirements(name)
    self:log("Checking requirements of " .. name .. "...")
    
    self:log("Reading requirements from file " .. self.dpmPath .. self.config.scriptPath .. name)
    local file = fs.open(self.dpmPath .. self.config.scriptPath .. name, "r")

    local requires = {}
    while true do
        local line = file.readLine()
        if not line then break end

        local find = string.find(line, "--@requires")
        if find then
            line = string.sub(line, find + 12)
            local lineEnd = string.find(line, " ")
            if lineEnd then
                requires[#requires + 1] = string.sub(line, 0, lineEnd - 1)
            else
                requires[#requires + 1] = string.sub(line, 0)
            end

            self:log("Found requirement: " .. requires[#requires])
            if fs.exists(self.dpmPath .. self.config.scriptPath .. requires[#requires]) then
                self:log("Requirement already satisfied!")
            else
                self:log("Missing requirement " .. requires[#requires])
                self:log("Trying to install " .. requires[#requires])
                local n = requires[#requires]
                if string.find(n, "@") then
                    n, code = self:getNameCode(n)
                    self:installScript(n, code)
                else
                    self:installGit(n)
                end
                self:checkRequirements(n)
            end
        end
    end
    
    self:log("Done")
end

function dpm:updateScript (name)
    self:log("Updating script: " .. name)
    local url = self:getGitURL(name)
    self:log("Checking " .. url .. "...")
    if http.checkURL(url) then
        self:log("Found! Installing from " .. url .. "...")
        self:installGit(name)
        self:log("Done")
    else
        self:log("Could not load from " .. url)
        self:log("Checking for code...")
        local code = self.scripts[name]
        
        if not code then
            self:log("Error! Script does not exist.")
        else
            self:log("Code found: " .. code)
            shell.run("pastebin", "run", self.config.installScriptCode .. " " .. code .. " " .. self.dpmPath .. self.config.scriptPath .. name)
            self:log("Done")
        end
    end
end

function dpm:updateAllScripts ()
    self:log("Updating all scripts...")
    for name, _ in pairs(self.scripts) do
        self:updateScript(name)
    end
    self:log("Done")
end

function dpm:update ()
    self:log("Updating dpm...")
    shell.run("pastebin", "run", self.config.installScriptCode .. " " .. self.config.code .. " dpm")
    self:log("Done")
end

function dpm:removeScript (name)
    self:log("Removing script: " .. name)
    local o = {}
    for n, code in pairs(self.scripts) do
        if n ~= name then
            o[n] = code
        else 
            self:log("Removed script from " .. self.dpmPath .. self.config.scriptListPath)
        end
    end
    self.scripts = o
    self:saveScripts()

    if fs.exists(self.dpmPath .. self.config.scriptPath .. name) then
        fs.delete(self.dpmPath .. self.config.scriptPath .. name)
        self:log("Removed script from " .. self.dpmPath .. self.config.scriptPath .. name)
    else
        self:log("File does not exists: " .. self.dpmPath .. self.config.scriptPath .. name)
    end

    self:log("Done")
end

function dpm:removeAllScripts ()
    self:log("Removing all scripts...")
    for name, _ in pairs(self.scripts) do
        self:removeScript(name)
    end
    self:log("Done")
end

function dpm:list ()
    print ("name", "code")
    print ("------------")
    for name, code in pairs(self.scripts) do
        print (name, code)
    end
end

function dpm:saveConfig()
    self:log("Saving config...")
    local file = fs.open(self.configFilePath, "w")
    file.write (textutils.serializeJSON(self.config))
    file.close()
    self:log("Done")
end

function dpm:loadConfig()
    self:log("Loading config...")
    local file = fs.open(self.configFilePath, "r")

    if not file then
        self:log("Error! File does not exist: " .. self.configFilePath)
        self:saveConfig()
    else
        local temp = textutils.unserializeJSON(file.readAll()) or {}
        if tablelength(temp) == tablelength(self.config) then
            self.config = temp
        else self:saveConfig() end
        self:log("Done")
        file.close()
    end

end

function dpm:updateConfig (name, value)
    local writeConfig = true
    if name and value then
        if self.config[name] ~= nil then
            if type(self.config[name]) == type(true) then
                if value == "true" then self.config[name] = true
                elseif value == "false" then self.config[name] = false
                else self:log("Error! Value has to be true or false.") end
            else
                -- We assume string
                self.config[name] = value
            end
        else
            writeConfig = false
            self:log("Error! There is no config for a variable named " .. name)
        end

        if writeConfig then
            dpm:saveConfig()
        end
    else
        print ("You can currently configure the following variables:")
        for name, value in pairs(self.config) do
            print (name, tostring(value))
        end
    end
end

function dpm:help (command)    
    if command and self.commandHelp[command] then
        print (self.commandHelp[command])
        return
    end

    for _, description in pairs(self.commandHelp) do
        print (description)
    end
end

function dpm:init ()
    fs.makeDir(self.dpmPath .. self.config.scriptPath)
    self:loadConfig()
    self:getScripts()
end

function dpm:checkArguments (args, offset)
    local firstArgument = offset + 1
    local name = args[firstArgument + 1]
    local value = args[firstArgument + 2]

    if name and not value and string.find(name, "@") then
        name, value = self:getNameCode(name)
    end

    if args[firstArgument] == "install" then
        if value and name then
            self:installScript(name, value)
            self:checkRequirements(name)
        else
            local url = self:getGitURL(name)
            if (http.checkURL(url)) then
                self:installGit(name)
                self:checkRequirements(name)
            else
                self:log("Error! Could not install script with name: " .. name)
            end
        end
    elseif args[firstArgument] == "update" then
        if name then
            if name == "all" then
                self:updateAllScripts()
            else
                self:updateScript(name)
            end
        else
            self:update()
        end
    elseif args[firstArgument] == "remove" then
        if name then
            if name == "all" then
                self:removeAllScripts()
            else
                self:removeScript(name)
            end
        else
            self:log("Error! Missing argument. What should I remove?")
        end
    elseif args[firstArgument] == "list" then
        if name then
            self:log("Error! Too many arguments.")
        else
            self:list()
        end
    elseif args[firstArgument] == "help" then        
        self:help(name)
    elseif args[firstArgument] == "config" then
        self:updateConfig(name, value)
    end
end

function dpm:load(name)
    self:log("Loading script " .. name .. "...")

    local code = nil
    if string.find(name, "@") then
        name, code = self:getNameCode(name)
    end

    if not fs.exists(self.dpmPath .. self.config.scriptPath .. name) then
        self:log("Error! Script does not exist: " .. self.dpmPath .. self.config.scriptPath .. name)
        if code then
            self:log("Trying to install " .. name .. " with code " .. code .. "...")
            self:installScript(name, code)
            self:checkRequirements(name)
        else
            local url = self:getGitURL(name)
            if (http.checkURL(url)) then
                self:installGit(name)
                self:checkRequirements(name)
            else
                self:log("Error! Could not install script with name: " .. name)
            end
        end
    else
        self:checkRequirements(name)
        local path = self.dpmPath .. self.config.scriptPath .. name
        local script = require(path)
        return script
    end

    return nil
end

--- Initialise
-- Check -v / -verbose flag to enable verbose output without saving config directly
local argOffset = 0
if args[1] == "-v" or args[1] == "-verbose" then
    argOffset = 1
    dpm.verbose = true
end
dpm:init()
--- Check arguments
if args[argOffset + 1] then
    dpm:checkArguments(args, argOffset)
end
-------------------

return dpm
