
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



local ECSComponent = {
    ClassName = "ECSComponent";
}

ECSComponent.__index = ECSComponent


function ECSComponent:ContainsInstance(instance)
    if (self.Instance ~= nil) then
        return self.Instance:IsAncestorOf(instance)
    end

    return false
end


function ECSComponent:_Destroy()

end


function ECSComponent:Destroy()
    self:_Destroy()
    
    if (self.Instance ~= nil) then
        self.Instance:Destroy()
    end

    setmetatable(self, nil)
end


function ECSComponent.new(componentDesc, data, instance)
    assert(type(componentDesc) == "table" and componentDesc._IsComponentDescription == true)

    data = data or {}
    assert(type(data) == "table")

    instance = instance or data.Instance

    local self = setmetatable({}, ECSComponent)

    self._ComponentName = componentDesc.ComponentName
    self._Destroy = DeepCopy(systemDesc.Destroy)
    
    AltMerge(self, componentDesc.Data)

    if (instance == nil) then
        instance = componentDesc:CreateInstance(data)
    end

    assert(instance == nil or typeof(instance) == "Instance")

    componentDesc:FromInstance(instance, data)
    componentDesc:Create(data)

    AltMerge(self, data)
    self.Instance = instance

    return self
end


return ECSComponent