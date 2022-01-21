--- Sequential table containing entity component data.
-- @classmod ComponentArray

local ComponentArray = {}
ComponentArray.__mt = { __index = ComponentArray }

--- Constructs a new ComponentArray.
-- @tparam function constructor A function which returns component data. 
-- @treturn ComponentArray
ComponentArray.new = function(constructor)
    return setmetatable({
        constructor = constructor,
        entities    = {}
    }, ComponentArray.__mt)
end

--- Constructs a new component for the given entity.
-- @tparam number entity An entity's ID.
-- @tparam {...} ... Arguments unique to the constructor.
ComponentArray.construct = function(self, entity, ...)
    self.entities[entity] = self.constructor(...)
end

--- Returns a reference to the given entity's component data.
-- @tparam number entity An entity's ID.
-- @treturn {...} Data unique to the component.
ComponentArray.peak = function(self, entity)
    return self.entities[entity]
end

--- Destroys the component data of the given entity.
-- @tparam number entity An entity's ID.
ComponentArray.destroy = function(self, entity)
    self.entities = nil
end
    
--- Returns true/false if the given entity has component data.
-- @tparam entity number An entity's ID.
-- @treturn bool If the entity has this ComponentArray's component data.
ComponentArray.has = function(self, entity)
    return self.entities[entity] ~= nil
end

return setmetatable(ComponentArray, {
    __call = function(...)
        return ComponentArray.new(...)
    end
})
