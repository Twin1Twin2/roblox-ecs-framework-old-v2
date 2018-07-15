
local ECSEntity = require(script.Parent.ECSEntity)

local Table = require(script.Parent.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable

local COMPONENT_DESC_CLASSNAME = "ECSComponentDescription"

local ECSWorld = {
    ClassName = "ECSWorld";
}

ECSWorld.__index = ECSWorld


function ECSWorld:GetEntityFromInstance(instance)
    for _, entity in pairs(self._Entities) do
        if (entity:ContainsInstance(instance) == true) then
            return entity
        end
    end

    return nil
end


function ECSWorld:GetSystem(systemName)
    for _, system in pairs(self._Systems) do
        if (system.ClassName == systemName) then
            return system
        end
    end

    return nil
end


function ECSWorld:_GetComponentDescription(componentName)
    return self._RegisteredComponents[componentName]
end


function ECSWorld:_CreateComponent(componentName, data)
    local componentDesc = self:_GetComponentDescription(componentName)
    local newComponent = ECSComponent.new(componentDesc, data)

    return newComponent
end


function ECSWorld:RegisterComponent(componentDesc)
    if (typeof(componentDesc) == "Instance" and componentDesc:IsA("ModuleScript") == true) then
        local success, message = pcall(function()
            componentDesc = require(componentDesc)
        end)

        assert(success == true, message)
    end

    assert(type(componentDesc) == "table", "")
    assert(componentDesc.ClassName == COMPONENT_DESC_CLASSNAME, "ECSWorld :: RegisterComponent() Argument [1] is not a ComponentDesc")

    local componentName = componentDesc.Name

    if (self._RegisteredComponents[componentName] ~= nil) then
        warn("ECS World " .. self.Name .. " - Component already registered with the name " .. componentName)
    end

    self._RegisteredComponents[componentName] = componentDesc
end


function ECSWorld:RegisterComponents(...)
    local componentDescs = {...}

    self:RegisterComponentsFromList(componentDescs)
end


function ECSWorld:RegisterComponentsFromList(componentDescs)
    assert(type(componentDescs) == "table", "")

    for _, componentDesc in pairs(componentDescs) do
        self:RegisterComponent(componentDesc)
    end
end


function ECSWorld:EntityComponentsChanged(entity)
    table.insert(self._EntitiesToUpdate, entity)
end


function ECSWorld:_AddEntity(entity)
    if (entity.Instance ~= nil) then
        entity.Instance.Parent = self.RootInstance
    end
end


function ECSWorld:_RemoveEntity(entity)  --remove from root instance and destroy components
    if (entity.Instance ~= nil) then
        entity.Instance.Parent = nil
    end

    entity:Destroy()
end


function ECSWorld:CreateEntity(entityData, altEntityData)
    local instance = nil
    local componentList = nil

    if (typeof(entityData) == "Instance") then
        instance = entityData
    elseif (typeof(altEntityData) == "Instance") then
        instance = altEntityData
    end

    if (type(entityData) == "table") then
        componentList = entityData
    elseif (type(altEntityData) == "table") then
        componentList = altEntityData
    end

    local entity = ECSEntity.new(instance)

    ECSWorld.AddComponentsToEntity(self, entity, componentList)
end


function ECSWorld:RemoveEntity(entity)
    --find entity
    --remove entity
end


function ECSWorld:_AddComponentToEntity(entity, componentName, componentData)
    assert(type(componentName) == "string" and type(componentData) == "table")

    local newComponent = self:_CreateComponent(componentName, componentData)
    entity:AddComponent(componentName, newComponent)
end


function ECSWorld:AddComponentsToEntity(entity, componentList)
    assert(entity ~= nil and type(entity) == "table" and entity.ClassName == "ECSEntity")
    assert(componentList ~= nil and type(componentList) == "table")

    for componentName, componentData in pairs(componentList) do
        ECSWorld._AddComponentToEntity(entity, componentName, componentData)
    end

    self:EntityComponentsChanged(entity)
end


function ECSWorld:RemoveComponentsFromEntity(entity, componentList)

    self:EntityComponentsChanged(entity)
end


function ECSWorld:_EntityBelongsInSystem(system, entity)
    local systemComponents = system.Components

    local hasValidComponents = entity:HasComponents(systemComponents)

    return hasValidComponents
end


function ECSWorld:_UpdateEntity(entity)  --update after it's components have changed or it was just added
    for _, systemName in pairs(entity:GetRegisteredSystems()) do
        local system = self:GetSystem(systemName)
        
        if (system ~= nil and self:_EntityBelongsInSystem(system, entity) == false) then
            system:RemoveEntity(entity)
        end
    end

    for _, system in pairs(self._Systems) do
        if (self:_EntityBelongsInSystem(system, entity) == true) then
            system:AddEntity(entity)
        end
    end
end

--
function ECSWorld:_UpdateEntities()
    if (#self._EntitiesToAdd > 0) then
        for _, entity in pairs(self._EntitiesToAdd) do
            if (TableContains(self._Entities, entity) == false) then
                table.insert(self._Entities, entity)
                table.insert(self._EntitiesToUpdate, entity)

                if (entity.Instance ~= nil) then
                    entity.Instance.Parent = self.RootInstance
                end
            end
        end

        self._EntitiesToAdd = {}
    end

    if (#self._EntitiesToRemove > 0) then
        for _, entity in pairs(self._EntitiesToRemove) do
            if (TableContains(self._Entities, entity) == true) then
                local registeredSystems = {}

                for _, systemName in pairs(entity:GetRegisteredSystems()) do --i'm not sure why self works
                    table.insert(registeredSystems, systemName)
                end

                for _, systemName in pairs(registeredSystems) do
                    local system = self:GetSystem(systemName)
                    if (system ~= nil) then
                        system:RemoveEntity(entity)
                    end
                end

                AttemptRemovalFromTable(self._Entities, entity)
                table.insert(self._EntitiesToUpdateRemoval, entity)
            end
        end

        self._EntitiesToRemove = {}
    end

    if (#self._EntitiesToUpdate > 0) then
        for _, entity in pairs(self._EntitiesToUpdate) do
            if (TableContains(self._Entities, entity) == true and TableContains(self._EntitiesToUpdateRemoval, entity) == false) then
                self:_UpdateEntity(entity)
            end
        end
    end
end
--]]

function ECSWorld:_UpdateRemovedEntities()   --check if all of the systems have unregistered from the entity before removing instance
    if (#self._EntitiesToUpdateRemoval > 0) then
        for _, entity in pairs(self._EntitiesToUpdateRemoval) do
            local numSystems = entity:GetNumberOfRegisteredSystems()
            if (numSystems == 0) then
                AttemptRemovalFromTable(self._EntitiesToUpdateRemoval, entity)
                self:_RemoveEntity(entity)
            end
        end
    end
end


function ECSWorld:Update()
    self:_UpdateEntities()
    self:_UpdateRemovedEntities()
end


function ECSWorld.new(name, rootInstance)
    name = name or "ECS_WORLD"
    assert(type(name) == "string")

    if (rootInstance == nil) then
        rootInstance = Instance.new("Folder")
    end

    assert(typeof(rootInstance) == "Instance")
    rootInstance.Name = name

    local self = setmetatable({}, ECSWorld)

    self.Name = name

    self.RootInstance = rootInstance

    self._Entities = {}

    self._EntitiesToAdd = {}
    self._EntitiesToRemove = {}
    self._EntitiesToUpdate = {}
    self._EntitiesToUpdateRemoval = {}

    self._RegisteredComponents = {}

    self._Systems = {}


    return self
end