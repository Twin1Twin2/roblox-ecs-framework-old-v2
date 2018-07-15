
local ECSComponentDescription = {
    ClassName = "ECSComponentDescription";
}

ECSComponentDescription.__index = ECSComponentDescription


function ECSComponentDescription:Extend(componentName)
    assert(type(componentName) == "string")

    local componentDesc = {
        ComponentName = componentName;
        Data = {};

        _IsComponentDescription = true;
    }

    setmetatable(componentDesc, self)


    return componentDesc
end


return ECSComponentDescription