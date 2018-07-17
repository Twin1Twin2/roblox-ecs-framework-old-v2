--NOT USED. PLZ IGNORE
local ECSSystemDescription = {
    ClassName = "ECSSystemDescription";
}

ECSSystemDescription.__index = ECSSystemDescription


function ECSSystemDescription:Extend(name)
    assert(type(name) == "string")

    local this = setmetatable({}, self)

    this.SystemName = name
    this.Components = {}

    this._IsSystemDescription = true


    return this
end


return ECSSystemDescription