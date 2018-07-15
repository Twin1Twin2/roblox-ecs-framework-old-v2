
local Table = require(script.Parent.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable

local COMPONENT_CLASSNAME = "ECSComponent"


local ECSEntity = {
    ClassName = "ECSEntity";
}

ECSEntity.__index = ECSEntity


function ECSEntity:HasComponents(...)
    local components = {...}
    local hasAllComponents = true

    if (type(components[1]) == "table") then
        components = components[1]
    end

    if (#components == 0) then
        return false
    end

    for _, componentName in pairs(components) do
        if (self._Components[componentName] == nil) then
            hasAllComponents = false
        end
    end

    return hasAllComponents
end


function ECSEntity:ContainsInstance(instance)
    if (self.Instance ~= nil) then
        return self.Instance:IsAncestorOf(instance)
    end

    return false
end


function ECSEntity:GetNumberOfRegisteredSystems()
    return #self._RegisteredSystems
end


function ECSEntity:GetRegisteredSystems()
    return self._RegisteredSystems
end


function ECSEntity:GetComponent(componentName)
    return self._Components[componentName]
end


function ECSEntity:AddComponent(componentName, component)
    assert(type(componentName) == "string")
    assert(type(component) == "table" and component.ClassName == COMPONENT_CLASSNAME)

    local comp = self._Components[componentName]

    if (comp ~= nil) then
        self:RemoveComponent(componentName, comp)
    end

    self._Components[componentName] = component

    if (component.Instance ~= nil) then
        component.Instance.Parent = self.Instance
    end
end


function ECSEntity:_RemoveComponent(componentName, component)
    self._Components[componentName] = nil

    if (component.Instance ~= nil) then
        --self._ChildrenRemoved[component.Instance] = component.Instance
        component.Instance.Parent = nil
    end

    component:Destroy()
end


function ECSEntity:RemoveComponent()
    
end


function ECSEntity:RegisterSystem(system)
    local systemName = system.ClassName

    if (TableContains(self._RegisteredSystems, systemName) == false) then
        table.insert(self._RegisteredSystems, systemName)
    end
end


function ECSEntity:UnregisterSystem(system)
    AttemptRemovalFromTable(self._RegisteredSystems, system.ClassName)
end


function ECSEntity:RemoveSelf()
    if (self.World ~= nil) then
        self.World:RemoveEntity(self)
    end
end


function ECSEntity:_ChildInstanceRemoved(instance)
    if (self._ChildrenRemoved[instance] ~= nil) then
        self._ChildrenRemoved[instance] = nil
        return
    end

    --find the component and remove it
    for _, component in pairs(self._Components) do
        if (component.Instance == instance) then
            self:RemoveComponent(component.ClassName, component)
            break
        end
    end
end


function ECSEntity:Destroy()
    if (self._ChildRemovedConnection ~= nil) then
        self._ChildRemovedConnection:Disconnect()
    end

    self._ChildRemovedConnection = nil
    self._ChildrenRemoved = nil


    for componentName, component in pairs(self._Components) do
        self:RemoveComponent(componentName, component)
    end

    if (self.Instance ~= nil) then
        self.Instance:Destroy()
    end


    self.World = nil
    self._Components = nil
    self._RegisteredSystems = nil
    

    setmetatable(self, nil)
end


function ECSEntity.new(instance)
    if (instance == nil) then
        instance = Instance.new("Model")
    end

    assert(typeof(instance) == "Instance")


    local self = setmetatable({}, ECSEntity)

    self.Instance = instance

    self.World = nil

    self._Components = {}
    self._RegisteredSystems = {}

    --[[
    self._ChildrenRemoved = {}
    self._ChildRemovedConnection = instance.ChildRemoved:Connect(function(child)
        self:_ChildInstanceRemoved(child)
    end)
    --]]


    return self
end


return ECSEntity