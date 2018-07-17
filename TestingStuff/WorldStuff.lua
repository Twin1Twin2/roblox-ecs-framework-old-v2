
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ECSFramework = require("ECSFramework")

local componentsList = {
    Component1;
    Component2;
    Component3;
}

local systemsList = {
    System1.new();
    System2.new();
    System3.new();
}


local world = ECSFramework.World.new()
world:RegisterComponents(componentsList)
world:RegisterSystems(systemsList)


return world