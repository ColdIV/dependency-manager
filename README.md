# Dependency Manager
A dependency manager for scripts to use in the mod CC: Tweaked of Minecraft.

# Install
To install run the following script in your computers / turtles console:

`pastebin run FuQ3WvPs KqhwihZr dpm`

# Example Program
Use `dpm get exampleProgram` to install.
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

local examplePrint = require("cldv.dpm.libs.examplePrint")

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

local exampleNumber = require("cldv.dpm.libs.exampleNumber")

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

## Get programs
- `dpm get <name>`

  Downloads the program <name> from this repository.
- `dpm get <name@pastebin code>`

  Downloads the program <name> from pastebin
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

# Contribute
**You are welcome to contribute your own scripts!**

To do that please create a pull request and add your script to the others in `libs/`.

Also please add your library / program to the respective json file within the `data` folder in the `gh-pages` branch.

If there still is no program inside of the `programs.json`, you can just copy the style of `libs.json`.

**Or,** if you know how to improve the **Dependency Manager** itself, you are very welcome to create a pull request for that as well!

Even if it is *just* an update of fixing typos or adding useful comments / formatting.
