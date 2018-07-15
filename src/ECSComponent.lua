--taken from RobloxComponentSystem by tiffany352

local function deepCopy(source)
	if typeof(source) == 'table' then
		local new = {}
		for key, value in pairs(source) do
			new[deepCopy(key)] = deepCopy(value)
		end
		return new
	end
	return source
end

local function merge(to, from)
	for key, value in pairs(from or {}) do
		to[deepCopy(key)] = deepCopy(value)
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


function ECSComponent:Destroy()
    if (self.Instance ~= nil) then
        self.Instance:Destroy()
    end
end


function ECSComponent.new(componentDesc, data, instance)
    assert(type(componentDesc) == "table" and componentDesc._IsComponentDescription == true)

    data = data or {}
    assert(type(data) == "table")

    instance = instance or data.Instance
    assert(instance == nil or typeof(instance) == "Instance")


    local self = setmetatable({}, ECSComponent)

    self._ComponentName = componentDesc.ComponentName

    if (instance == nil) then
        local newInstance = Instance.new("Folder")
        self.Instance = newInstance
    else
        self.Instance = instance
    end

    self.Instance.Name = tostring(self.ComponentName)
    

    local newData = deepCopy(componentDesc.Data)

    componentDesc:FromInstance(instance, newData)
    componentDesc:Create(data)

    merge(newData, data)
    merge(self, newData)

    return self
end


return ECSComponent