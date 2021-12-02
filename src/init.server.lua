-- metatablecat 2021
-- Licensed under Apache 2.0

local CoreGui = game:GetService("CoreGui")
local activeModule
local silenceManualDeletionWarning = false
local gameIsClosing = false

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

local findModuleAlready = CoreGui:FindFirstChild("CommandBarBridge")
if findModuleAlready then
	return
end

local function deployModule()
	activeModule = script.CommandBarBridge:Clone()
	activeModule.Parent = CoreGui

	activeModule.AncestryChanged:Connect(function(_, parent)
		if parent == nil and not silenceManualDeletionWarning then
			warn("The module was deleted. Please do not do this manually as it can create unhandlable issues.")
			deployModule()
		end
	end)
end

plugin.Unloading:Connect(function()
	silenceManualDeletionWarning = true

	if activeModule then
		activeModule:Destroy()
		activeModule = nil
	end

	if gameIsClosing then return end
	warn("The plugin was unloaded. Plugins that rely on this will not update until they are also reloaded.")
end)

deployModule()

game:BindToClose(function()
	gameIsClosing = true
end)