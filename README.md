# vmbridge

A simple Plugin <> CommandBar sync module.

# Installation
There are two ways to install this plugin
* Download the Plugin.rbxm model and save it to `%LOCALAPPDATA%/Roblox/Plugins`
* [Use the Roblox Plugin](https://www.roblox.com/library/8107839697/vmbridge)

# Developer Usage
All methods are exposed under `CoreGui.CommandBarBridge` once the plugin has loaded

A basic injector that you can use is located [here](https://github.com/metatablecat/vmbridge/blob/main/examples/CommandBarInjector.lua)

# API

`CommandBarBridge:Listen() -> ()`

Only used for command bar injection. Do not call this within plugins as it may have unspecified behaviour.

`CommandBarBridge:IsInjected() -> boolean`

Returns if the bindable has been injected into the command bar

`RBXScriptSignal CommandBarBridge.Injected`

Fired when the command bar has been injected with Listen.

`CommandBarBridge.newInjectionHandler(module: ModuleScript) -> ModuleInjectionHandler`

Creates a new handler for the specified module script. This module will return a cached injection handler if it's already been created. It will error if the bindable is not injected.

`CommandBarBridge:ShowCommandBarWarning() -> ()`

Shows the `Please require...` message.

~~`CommandBarBridge:WaitForInjection(silent: boolean?) -> () [CanYield] [Deprecated]`~~

Checks if the bindable is injected, and yields if it's not. If `silent` is true, it will mute the `Please require...` warning.

This is deprecated as it creates difficulties with asynchronous code. Use `CommandBar.Injected` event instead. An example of how to do this is shown below:
```lua
if not CommandBarBridge:IsInjected() then
	CommandBarBridge:ShowCommandBarWarning()
	CommandBarBridge.Injected:Wait()
end
```

`ModuleInjectionHandler:Disconnect() -> ()`

Removes the injection cache from all sources. **ALWAYS CALL THIS WHEN UNLOADING PLUGINS**

`ModuleInjectionHandler:RunAction(actionName: string, ...: any) -> any...`

Calls an action in the injected module and returns it's value

# Building the CommandBarBridge module so that it can be used without needing the plugin.

Its possible to use the CommandBarBridge module on it's own in your plugins as long as you:
* Make the command bar able to reach it
* Ensure there are no clashes with other copies of this module

**I recommend building your plugins this way so the user doesn't need to install two plugins, the plugin itself is just used mostly to make it easier to develop with this**

# Warnings

Do not return functions or metatable tables inside your module code, functions are not allowed and tables can have unintended behaviour.
