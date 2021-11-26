local CoreGui = game:GetService("CoreGui")
local activeModule

local function RequestScriptAccessEarly()
	local didPerformAction = pcall(function()
		local probeScript = Instance.new("Script")
		probeScript.Parent = workspace
		probeScript:Destroy()
	end)

	return didPerformAction
end

if not RequestScriptAccessEarly() then
	warn("Please grant injection permissions so we can add the CommandBar bridge module")
	return
end

activeModule = script.CommandBarBridge:Clone()
activeModule.Parent = CoreGui

plugin.Unloading:Connect(function()
	if activeModule then
		require(activeModule):_Cleanup()
		activeModule = activeModule:Destroy()
	end
end)