
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ECSFramework = require("ECSFramework")
local IsInstanceValueInstance = require("IsInstanceValueInstance")


local MyComponent = ECSFramework.Component:Extend("MyComponent")

MyComponent.Data = {
    Potato = nil;
}


function MyComponent:FromInstance(instance, data)   --called when a component is created with an instance or the data's Instance index ~= nil
    --convert a component from an instance
    --if a component is created with an table that has an Instance attribute, then this will be called first before Create
    --the data returned from this function will be merged into the 'data' table value with the 'data' having priority
    
    local potatoValue = instance:FindFirstChild("Potato") or instance

    if (IsInstanceValueInstance(potatoValue) == true) then
        data.Potato = potatoValue.Value
    end
    
    return data
end


function MyComponent:Create(data)   --called when a component is created with a table
    --custom create to allow type checking
    --the data will then be merged into a new table with the data returned from this one 
end


function MyComponent:Destroy(data)
    --will custom delete the data (so if you want to delete any of the values instead of disconnecting them)
    
end


return MyComponent