-- This should be used within a plugin. Set the module you want to inject to the variable Module
-- metatablecat 2021
-- Licensed under Apache 2.0

local Plugin = script:FindFirstAncestorOfClass("Plugin")
local CoreGui = game:GetService("CoreGui")

local ActiveInjector
local Module = SET_ME_TO_A_MODULE_SCRIPT --set this to whatever module you want to inject
local ContinueYield = true

local function WaitForOneEvent(...)
	local connections = {}
	local resolve = Instance.new("BindableEvent")

	for _, e in ipairs{...} do
		connections[#connections + 1] = e.Event:Connect(function()
			resolve:Fire()
			for _, c in pairs(connections) do
				c:Disconnect()
			end
			connections = {}
		end)
	end

	resolve.Event:Wait()
end

local function Inject()
	while true do
		local CommandBarInjectionManager = CoreGui:WaitForChild("CommandBarBridge")
		local CommandBar = require(CommandBarInjectionManager)

		if not CommandBar:IsInjected() then
			WaitForOneEvent(CommandBar.Injected, Plugin.Unloading)
		end

		if not ContinueYield then
			return --we want to kill this thread, not inject again, because its running somewhere else
		end

		ActiveInjector = CommandBar.newInjectionHandler(Module)
	end
end

Plugin.Unloading:Connect(function()
	ContinueYield = false

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
