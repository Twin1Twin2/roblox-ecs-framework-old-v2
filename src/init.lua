
--goals:
--ecs framework should be it's own self contained modules. it should not use Nevermore to look for components
--the instance to ECS object compiler is the most important part of this framework. design around it
    --FromInstance method in ECSComponentDescription
    --GetEntityFromInstance method in ECSWorld
    --ContainsInstance method in ECSEntity
--Components are just tables (whose metatable points to ECSComponent). Tables that always have an Instance index whose value points to the component's instance representation
--Hybrid ECS
    --Entities have methods
    --Entities contain all of their component data in their _Components table (instead of it being in table with the UID as the index)


local ECSEngine = require(script.ECSEngine)
local ECSWorld = require(script.ECSWorld)
local ECSEntity = require(script.ECSEntity)
local ECSComponent = require(script.ECSComponent)
local ECSComponentDescription = require(script.ECSComponentDescription)
local ECSSystem = require(script.ECSSystem)


local ECSFramework = {}

ECSFramework.Engine = ECSEngine
ECSFramework.World = ECSWorld
ECSFramework.Component = ECSComponentDescription
ECSFramework.System = ECSSystem


return ECSFramework