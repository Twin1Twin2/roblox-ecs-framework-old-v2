
local ECSWorld = require(script.Parent.ECSWorld)
local ECSSystem = require(script.Parent.ECSSystem)


local RunService = game:GetService("RunService")


local ECSEngine = {
    ClassName = "ECSEngine";
}

ECSEngine.__index = ECSEngine

local LOCKMODE_OPEN = ECSSystem.LOCKMODE_OPEN
local LOCKMODE_LOCKED = ECSSystem.LOCKMODE_LOCKED
local LOCKMODE_ERROR = ECSSystem.LOCKMODE_ERROR


function ECSEngine:SetWorld(newWorld)
    if (self._World ~= nil) then
        self._World.RootInstance.Parent = nil
    end

    self._World = newWorld
    self._World.RootInstance.Parent = workspace
end


function ECSEngine:Update(stepped)
    if (self._World == nil) then
        return
    end

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
    if (self._World ~= nil) then
        self.T = t  --idk
    end

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


function ECSEngine.new(world)
    world = world or ECSWorld.new()


    local self = setmetatable({}, ECSEngine)

    self._World = nil
    
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


    return self
end


return ECSEngine