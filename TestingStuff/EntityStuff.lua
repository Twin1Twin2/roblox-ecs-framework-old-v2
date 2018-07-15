
local resources = game:GetService("ReplicatedStorage"):FindFirstChild("Resources")
local EntityResource = require("EntityResource")


local function EntityStuff(world)
    local entityInstance = resources.EntityInstance
    

    local entity = world:CreateEntity(entityInstance)

    local entity1 = world:CreateEntity{
        MyComponent0 = {Value = 1};
        MyComponent1 = {Value = 2};
    }

    local entity2 = world:CreateEntity{
        Instance = entityInstance;

        MyComponent0 = {Value = 0};
        MyComponent1 = {Value = 2};
    }

    local entity3 = world:CreateEntity(entityInstance,
        {
            MyComponent0 = {Value = 0};
            MyComponent1 = {Value = 2};
        }
    )

    local entity5 = world:CreateEntity(EntityResource)

    local entity6 = world:CreateEntity(EntityResource,
        {
            MyComponent0 = {Value = 0};
            MyComponent1 = {Value = 2};
        }
    )
end


return EntityStuff