# Dependency Manager
A dependency manager for scripts to use in the mod CC: Tweaked of Minecraft.

# Example Program
```lua
-- exampleProgram.lua
local dpm = require("dpm")

local example = dpm:load("example")

example:test()
```
Loads the library `example` and its dependencies.

If the file cannot be found locally it will search for it within this repository or on pastebin if the code has previously been saved to the `scripts.json`.

# Example Libraries
```lua
-- example.lua
--@requires examplePrint

local obj = {}

local examplePrint = require("dpm.libs.examplePrint")

function obj:test()
    examplePrint:printRandomNumber()
end

return obj
```
**Note: The comment: `--@requires examplePrint` is required to check for and install the library `examplePrint` if it is not yet installed.**

```lua
-- examplePrint.lua
--@requires exampleNumber@QsN94px9

local obj = {}

local exampleNumber = require("dpm.libs.exampleNumber")

function obj:printRandomNumber ()
    print ("It works! Random Number: " .. exampleNumber)
end

return obj
```
**Note: Here the require comment has a pastebin code within it, this will make sure to install the file from pastebin if it is not yet installed.**

```lua
-- exampleNumber.lua (from https://pastebin.com/QsN94px9)
return math.random(1,100)
```

# Run
To run, just run `exampleProgram` normally, without bothering to install any of the dependencies. **dpm** will handle that for you.

# Install
To install run the following script in your computers / turtles console:

`pastebin run FuQ3WvPs KqhwihZr dpm`

# dpm arguments
There are a bunch of commands you can use with the Dependency Manager (dpm):

## Install libs via
- `dpm install <name in git repo>`

  Installs scripts which are in this repository in libs/
- `dpm install <name> <pastebin code>`

  Installs scripts from pastebin
- `dpm install <name@pastebin code>`

  Also installs scripts from pastebin

## Update libs
- `dpm update <name>`

  Updates libs by name (with stored pastebin code or from this repository)
- `dpm update all`

  Update all scrippts

## Remove libs
- `dpm remove <name>`

  Removes lib with given name
- `dpm remove all`

  Removes all libs

## List all installed libs
- `dpm list`

## Configure settings
- `dpm config`

  Shows current configuration
- `dpm config <name> <value>`

  Change configuration of variable with name to given value
  
## Help
- `dpm help`

  Shows info to all commands
- `dpm help <argument name>`

  Shows info to a specific command
