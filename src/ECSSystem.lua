
local Table = require(script.Parent.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable
local Merge = Table.Merge
local DeepCopy = Table.DeepCopy

local function AltDeepCopy(source)   --copied from RobloxComponentSystem by tiffany352
	if typeof(source) == 'table' then
		local new = {}
		for key, value in pairs(source) do
			new[AltDeepCopy(key)] = AltDeepCopy(value)
		end
		return new
	end
	return source
end

local function AltMerge(to, from)   --copied from RobloxComponentSystem by tiffany352
	for key, value in pairs(from or {}) do
		to[DeepCopy(key)] = DeepCopy(value)
	end
end


local ECSSystem = {
    ClassName = "ECSSystem";

    LOCKMODE_OPEN = 0;
    LOCKMODE_LOCKED = 1;
    LOCKMODE_ERROR = 2;
}

ECSSystem.__index = ECSSystem

--
local INDEX_BLACKLIST = {
    ClassName = true;

    LOCKMODE_OPEN = true;
    LOCKMODE_LOCKED = true;
    LOCKMODE_ERROR = true;

    SetLockMode = true;
    AddEntity = true;
    RemoveEntity = true;
    _AddEntity = true;
    _RemoveEntity = true;

    _EntitiesToAdd = true;
    _EntitiesToRemove = true;

    World = true;
    Entities = true;
}

local VIRTUAL_FUNCTIONS = {
    Initialize = true;
    EntityAdded = true;
    EntityRemoved = true;
}
--]]

function ECSSystem:_AddEntity(entity)
    if (TableContains(self.Entities, entity) == false) then
        table.insert(self.Entities, entity)

        entity:RegisterSystem(self) --change to ECSEntity.RegisterSystem(entity, self) ?

        self:EntityAdded(entity)
    end
end


function ECSSystem:_RemoveEntity(entity)
    local wasRemoved = AttemptRemovalFromTable(self.Entities, entity)
    if (wasRemoved == true) then
        entity:UnregisterSystem(self)

        self:EntityRemoved(entity)
    end
end


function ECSSystem:SetLockMode(newLockMode)
    self.LockMode = newLockMode

    if (#self._EntitiesToAdd > 0) then
        for _, entity in pairs(self._EntitiesToAdd) do
            self:_AddEntity(entity)
        end

        self._EntitiesToAdd = {}
    end

    if (#self._EntitiesToRemove > 0) then
        for _, entity in pairs(self._EntitiesToRemove) do
            self:_RemoveEntity(entity)
        end

        self._EntitiesToRemove = {}
    end
end


function ECSSystem:AddEntity(entity)
    local lockMode = self.LockMode

    if (lockMode == LOCKMODE_OPEN) then
        self:_AddEntity(entity)
    elseif (lockMode == LOCKMODE_LOCKED) then
        if (TableContains(self.Entities, entity) == false and TableContains(self._EntitiesToAdd, entity) == false) then
            table.insert(self._EntitiesToAdd, entity)
        end
    elseif (lockMode == LOCKMODE_ERROR) then
        error("Cannot add or remove entities at this time!", 2)
    end
end


function ECSSystem:RemoveEntity(entity)
    local lockMode = self.LockMode

    if (lockMode == LOCKMODE_OPEN) then
        self:_RemoveEntity(entity)
    elseif (lockMode == LOCKMODE_LOCKED) then
        if (TableContains(self.Entities, entity) == true and TableContains(self._EntitiesToRemove, entity) == false) then
            table.insert(self._EntitiesToRemove, entity)
        end
    elseif (lockMode == LOCKMODE_ERROR) then
        error("Cannot add or remove entities at this time!", 2)
    end
end


function ECSSystem:Initialize()

end


function ECSSystem:EntityAdded(entity)

end


function ECSSystem:EntityRemoved(entity)

end


function ECSSystem:Update(stepped)
    
end


function ECSSystem:Destroy()
    setmetatable(self, nil)
end


function ECSSystem:Extend(name)
    assert(type(name) == "string")

    local this = {}

    setmetatable(this, ECSSystem)
    this.__index = this

    this.SystemName = name

    function this.new()
        local t = setmetatable(ECSSystem.new(name), this)

        for index, value in pairs(this) do
            if (INDEX_BLACKLIST[index] ~= nil) then
                t[index] = DeepCopy(value)
            end
        end

        return t
    end
end


function ECSSystem.new(name, world)
    assert(type(name) == "string")

    local self = setmetatable({}, ECSSystem)

    self.SystemName = name

    self.LockMode = LOCKMODE_OPEN

    self._EntitiesToAdd = {}
    self._EntitiesToRemove = {}

    self.World = world or nil
    self.Components = {}    --the names of the components this system needs
    self.Entities = {}


    return self
end


return ECSSystem