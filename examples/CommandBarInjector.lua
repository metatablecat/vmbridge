-- This should be used within a plugin. Set the module you want to inject to the variable Module
-- metatablecat 2021
-- Licensed under Apache 2.0

local Plugin = script:FindFirstAncestorOfClass("Plugin")
local CoreGui = game:GetService("CoreGui")
local WaitSignal = Instance.new("BindableEvent")

local ActiveInjector
local Module = SET_ME_TO_A_MODULE_SCRIPT --set this to whatever module you want to inject
local cleanupEvent
local ContinueYield = true

local function Inject()
	while true do
		local CommandBarInjectionManager = CoreGui:WaitForChild("CommandBarBridge")
		local CommandBar = require(CommandBarInjectionManager)

		local didInject = CommandBar:WaitForInjection()
		if not ContinueYield then
			return --we want to kill this thread, not inject again, because its running somewhere else
		end

		if not didInject then
			continue
		end
		
		ActiveInjector = CommandBar.newInjectionHandler(Module)
		
		WaitSignal:Fire(ActiveInjector)
		
		local e
		CommandBar.Cleanup:Wait()
		ActiveInjector = nil
	end
end

Plugin.Unloading:Connect(function()
	ContinueYield = false

	if cleanupEvent then
		cleanupEvent:Disconnect()
		cleanupEvent = nil
	end
	
	if ActiveInjector then	
		ActiveInjector:Disconnect()
		ActiveInjector = nil
	end
end)

task.spawn(Inject)

return function(...)
	local injector = ActiveInjector
	if not injector then
		return false, "Not Injected"
	end
	
	return true, injector:RunAction(...)
end
