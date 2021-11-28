-- metatablecat 2021
-- Licensed under Apache 2.0

local HttpService = game:GetService("HttpService")

local Injected = false
local HasShownInjectionWarning = false

--We should be able to this all inside now
local StopYieldingSignal = Instance.new("BindableEvent")
local SignalBindable = Instance.new("BindableFunction")

local m = {}
m.Injected = StopYieldingSignal.Event

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

function m:ShowCommandBarWarning()
	warn(generateCommandBarWarning())
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

function m:WaitForInjection(silent: boolean)
	warn("This function is deprecated. Please use the Injected event instead. Check the README file under WaitForInjection on how to use the event")
	if Injected == true then return end

	if not HasShownInjectionWarning and not silent then
		self:ShowCommandBarWarning()
	end

	StopYieldingSignal.Event:Wait()
	Injected = true
end

type InjectionHandler = {
	GUID: string,
	RunAction: (InjectionHandler, string, ...any) -> ...any,
	Disconnect: (InjectionHandler) -> ()
}

function m.newInjectionHandler(module: ModuleScript): InjectionHandler
	if not Injected then
		error(generateCommandBarWarning())
	end

	local cached = CachedConnections[module]
	if cached then
		return cached
	end

	local name: string = HttpService:GenerateGUID(false)
	SignalBindable:Invoke("AddNewModuleToNamespace", name, module)

	local injection = {}
	injection.GUID = name

	function injection:RunAction(action: string, ...: any): ...any
		return SignalBindable:Invoke("PerformAction", name, action, ...)
	end

	function injection:Disconnect(): ()
		CachedConnections[module] = nil		
		--We wrap this because there's a chance this will be called before the injection is done
		AttemptSignal("RemoveModuleFromNamespace", name)
	end

	table.freeze(injection)

	CachedConnections[module] = injection
	return injection
end

type CommandBarBridge = {
	Injected: RBXScriptSignal,
	newInjectionHandler: () -> InjectionHandler,
	
	IsInjected: (CommandBarBridge) -> boolean,
	Listen: (CommandBarBridge) -> (),
	ShowCommandBarWarning: (CommandBarBridge) -> (),
	WaitForInjection: (CommandBarBridge, boolean) -> ()
}

table.freeze(m)
return m :: CommandBarBridge