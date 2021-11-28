-- This should be used within a plugin. Set the module you want to inject to the variable Module
-- metatablecat 2021
-- Licensed under Apache 2.0

local Plugin = script:FindFirstAncestorOfClass("Plugin")
local CoreGui = game:GetService("CoreGui")

local ActiveInjector
local Module =  --set this to whatever module you want to inject
local ContinueYield = true

local function Inject()
	local CommandBarInjectionManager = CoreGui:WaitForChild("CommandBarBridge")
	local CommandBar = require(CommandBarInjectionManager)

	--TODO: Update this to not use deprecated functions.
	CommandBar:WaitForInjection()
	if not ContinueYield then
		return --we want to kill this thread, not inject again, because its running somewhere else
	end

	ActiveInjector = CommandBar.newInjectionHandler(Module)
end

Plugin.Unloading:Connect(function()
	ContinueYield = false

	if ActiveInjector then	
		ActiveInjector:Disconnect()
		ActiveInjector = nil
	end
end)

Inject()
if not ActiveInjector then
	return false
end

return function(...)
	return ActiveInjector:RunAction(...)
end
