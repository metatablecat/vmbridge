-- metatablecat 2021
-- Licensed under Apache 2.0

local HttpService = game:GetService("HttpService")

local Injected = false
local HasShownInjectionWarning = false

--We should be able to this all inside now
local StopYieldingSignal = Instance.new("BindableEvent")
local SignalBindable = Instance.new("BindableFunction")

local m = {
	Injected = StopYieldingSignal.Event
}
local ModuleNamespace = {}
local CachedConnections = {}

local BINDABLE_ACTIONS = {
	AddNewModuleToNamespace = function(name, moduleToAdd)
		assert(not ModuleNamespace[name], name .. " is registered already")
		ModuleNamespace[name] = require(moduleToAdd)
	end,
	
	RemoveModuleFromNamespace = function(name)
		assert(ModuleNamespace[name], name .. " is not a registered module")
		ModuleNamespace[name] = nil
	end,
	
	PerformAction = function(name, action, ...)
		local module = assert(ModuleNamespace[name], name .. " is not a registered module")
		return module[action](...)
	end
}

local function AttemptSignal(...)
	if not Injected then
		return
	end

	return SignalBindable:Invoke(...)
end

local function generateCommandBarWarning()
	local path = "game."..script:GetFullName()
	local fmt = "Please run this in the command bar: require(%s):Listen()"
	return string.format(fmt, path)
end

function m:Listen()
	if Injected then
		warn("Already injected into the command bar VM.")
		return
	end
	
	SignalBindable.OnInvoke = function(connectionType, ...)
		local action = BINDABLE_ACTIONS[connectionType]
		return action(...)
	end
	
	Injected = true
	StopYieldingSignal:Fire()
end

function m:IsInjected()
	return Injected
end

function m:WaitForInjection(silent)
	if Injected == true then return end
	
	if not HasShownInjectionWarning and not silent then
		warn(generateCommandBarWarning())
		HasShownInjectionWarning = true
	end

	StopYieldingSignal.Event:Wait()
	Injected = true
end

function m.newInjectionHandler(module)
	if not Injected then
		warn(generateCommandBarWarning())
		return
	end
	
	local cached = CachedConnections[module]
	if cached then
		return cached
	end
	
	local name = HttpService:GenerateGUID(false)
	SignalBindable:Invoke("AddNewModuleToNamespace", name, module)
	
	local injection = {
		GUID = name
	}
	
	function injection:RunAction(action, ...)
		return SignalBindable:Invoke("PerformAction", name, action, ...)
	end
	
	function injection:Disconnect()
		CachedConnections[module] = nil		
		--We wrap this because there's a chance this will be called before the injection is done
		AttemptSignal("RemoveModuleFromNamespace", name)
	end
	
	--table.freeze(injection) pls enable this roblox
	
	CachedConnections[module] = injection
	return injection
end

return m