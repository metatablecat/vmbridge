# vmbridge

A simple Plugin <> CommandBar sync module.

# Installation
There are two ways to install this plugin
* Download the Plugin.rbxm model and save it to `%LOCALAPPDATA%/Roblox/Plugins%`
* ~~Use the Roblox Plugin~~

# Developer Usage
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

# API

`RBXScriptSignal CommandBarBridge.Unloading`

Signalled when CommandBarBridge's injector unloads.

CommandBarBridge cleans up what it can, but you should still use this when dealing with the injection unloading so that it can correctly be garbage collected.

`CommandBarBridge:_Cleanup() -> ()`

Used internally to unload the module. Do not call this as it will break everything.

`CommandBarBridge:Listen() -> ()`

Only used for command bar injection. Do not call this within plugins as it may have unspecified behaviour.

`CommandBarBridge:IsInjected() -> boolean`

Returns if the bindable has been injected into the command bar

`CommandBarBridge.newInjectionHandler(module: ModuleScript) -> ModuleInjectionHandler`

Creates a new handler for the specified module script. This module will return a cached injection handler if it's already been created. It will error if the bindable is not injected.

`CommandBarBridge:WaitForInjection(silent: boolean?) -> boolean [CanYield]`

Checks if the bindable is injected, and yields if it's not. If `silent` is true, it will mute the `Please require...` warning. Returns if the thread was continued from an injection or not.

This allows you to release and handle yielding threads if the injector plugin is unloaded

`ModuleInjectionHandler:Disconnect() -> ()`

Removes the injection cache from all sources. **ALWAYS CALL THIS WHEN UNLOADING PLUGINS**

`ModuleInjectionHandler:RunAction(actionName: string, ...: any) -> any...`

Calls an action in the injected module and returns it's value

# Warnings

Do not return functions or metatable tables inside your module code, functions are not allowed and tables can have unintended behaviour.
