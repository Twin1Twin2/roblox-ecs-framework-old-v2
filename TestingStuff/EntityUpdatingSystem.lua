
local ECSSystem


local EntityUpdatingSystem = {
    ClassName = "EntityUpdatingSystem";
}

setmetatable(EntityUpdatingSystem, ECSSystem)
EntityUpdatingSystem.__index = EntityUpdatingSystem

local LOCKMODE_OPEN = ECSSystem.LOCKMODE_OPEN
local LOCKMODE_LOCKED = ECSSystem.LOCKMODE_LOCKED
local LOCKMODE_ERROR = ECSSystem.LOCKMODE_ERROR


function EntityUpdatingSystem:UpdateSystem(stepped)
    self:SetLockMode(LOCKMODE_LOCKED)

    for _, entity in pairs(self.Entities) do
        self:Update(stepped, entity)
    end

    self:SetLockMode(LOCKMODE_OPEN)
end


function EntityUpdatingSystem.new()
    local self = setmetatable(ECSSystem.new(), EntityUpdatingSystem)



    return self
end


return EntityUpdatingSystem