# vmbridge

A simple Plugin <> CommandBar sync module.

# Installation
There are two ways to install this plugin
* Download the Plugin.rbxm model and save it to `%LOCALAPPDATA%/Roblox/Plugins%`
* ~~Use the Roblox Plugin~~

# Usage
All methods are exposed under `CoreGui.CommandBarBridge` once the plugin has loaded

A basic injector that you can use is:
```lua
local CoreGui = game:GetService("CoreGui")
local CommandBarInjectionManager = CoreGui:WaitForChild("CommandBarBridge")
local CommandBar = require(CommandBarInjectionManager)

local IsInjected = CommandBar:IsInjected()
if not IsInjected then
	CommandBar:WaitForInjection(true)
end

local Injector = CommandBar.newInjectionHandler(script.Parent.CommandBarCode)

return function(action, ...)
	return Injector:RunAction(action, ...)
end
```
