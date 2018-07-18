
local ECSWorld = require(script.Parent.ECSWorld)
local ECSSystem = require(script.Parent.ECSSystem)
local ECSEngineConfiguration = requie(script.Parent.ECSEngineConfiguration)

local RunService = game:GetService("RunService")


local ECSEngine = {
    ClassName = "ECSEngine";
}

ECSEngine.__index = ECSEngine

local LOCKMODE_OPEN = ECSSystem.LOCKMODE_OPEN
local LOCKMODE_LOCKED = ECSSystem.LOCKMODE_LOCKED
local LOCKMODE_ERROR = ECSSystem.LOCKMODE_ERROR


function ECSEngine:Update(stepped)
    self._World:Update()
end


function ECSEngine:RenderSteppedUpdate(stepped)
    for _, system in pairs(self._RenderSteppedUpdateSystems) do
        system:SetLockMode(LOCKMODE_ERROR)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function ECSEngine:SteppedUpdate(t, stepped)
    self.World.T = t  --idk

    for _, system in pairs(self._SteppedUpdateSystems) do
        system:SetLockMode(LOCKMODE_ERROR)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function ECSEngine:HeartbeatUpdate(stepped)
    for _, system in pairs(self._HeartbeatUpdateSystems) do 
        system:SetLockMode(LOCKMODE_LOCKED)
        system:Update(stepped)
        system:SetLockMode(LOCKMODE_OPEN)
    end
end


function ECSEngine:Destroy()
    
end


function ECSEngine.new(engineConfiguration)
    local self = setmetatable({}, ECSEngine)

    self._World = ECSWorld.new()
    
    self._RenderSteppedUpdateSystems = {}
    self._SteppedUpdateSystems = {}
    self._HeartbeatUpdateSystems = {}

    self._UpdateConnection = RunService.Heartbeat:Connect(function(stepped)
        self:Update(stepped)
    end)

    self._RenderSteppedUpdateConnection = RunService.RenderStepped:Connect(function(stepped)
        self:RenderSteppedUpdate(stepped)
    end)

    self._SteppedUpdateConnection = RunService.Stepped:Connect(function(t, stepped)
        self:SteppedUpdate(t, stepped)
    end)

    self._HeartbeatUpdateConnection = RunService.Heartbeat:Connect(function(stepped)
        self:HeartbeatUpdate(stepped)
    end)


    if (engineConfiguration ~= nil and engineConfiguration.ClassName == "ECSEngineConfiguration") then
        self._World:SetName(engineConfiguration.WorldName)

        self._World:RegisterComponents(engineConfiguration.Components)
        self._World:RegisterSystems(engineConfiguration.Systems)

        self._RenderSteppedUpdateSystems = engineConfiguration.RenderSteppedSystems
        self._SteppedUpdateSystems = engineConfiguration.SteppedSystems
        self._HeartbeatUpdateSystems = engineConfiguration.HeartbeatSystems
    end


    return self
end


return ECSEngine