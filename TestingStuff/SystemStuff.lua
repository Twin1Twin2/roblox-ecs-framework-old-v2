
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ECSFramework = require("ECSFramework")


local MySystem = ECSFramework.System:Extend("MySystem")

MySystem.Components = {
    "AComponent";
    "BComponent";
}


function MySystem:EntityAdded(entity)
    local world = self.World

    --world:AddComponentToEntity(entity, "MyComponent0", {Value = 1; Potato = "Hi"})
    --world:AddComponentToEntity(entity, "MyComponent1", {Value = 2; Instance = instance})
    --world:AddComponentToEntity(entity, "MyComponent2", {Value = 3, Potato = "Taco"}, instance)

    world:AddComponentsToEntity(entity,
        {
            MyComponent0 = {Value = 1, Instance = instance};    --will search for a registered component matching that desc
            MyComponent1 = MyComponent1Desc;
            whatevs = MyComponent2Desc; --will ignore the index as the Component classname and use the ComponentDesc's classname
            MyComponent3 = MyComponent3Desc:Extend{Value = 20; Instance = instance2};   --use a componentdesc but with custom values
        }
    )

    world:RemoveComponentsFromEntity(entity, {"MyComponent1", "MyComponent2"})
end


function MySystem:EntityRemoved(entity)

end


function MySystem:Update(stepped)
    for _, entity in pairs(self.Entities) do
        local componentA = entity:GetComponent("ComponentA")

        componentA.Value = componentA.Value + 1
    end
end


return MySystem