--- Sequential table containing entity component data.
-- @classmod ComponentArray

local ComponentArray = {}
ComponentArray.__mt = { __index = ComponentArray }

--- Construct a new ComponentArray.
-- @tparam func constructor A function which returns component data. 
-- @treturn ComponentArray
ComponentArray.new = function(constructor)
    return setmetatable({
        constructor = constructor,
        entities    = {}
    }, ComponentArray.__mt)
end

--- Construct a new component for the entity.
-- @tparam ComponentArray self
-- @tparam int entity An entity's ID.
-- @tparam {...} ... Arguments unique to the constructor.
ComponentArray.insert = function(self, entity, ...)
    self.entities[entity] = self.constructor(...)
end

--- Return the entity's component data.
-- @tparam ComponentArray self
-- @tparam int entity An entity's ID.
-- @treturn {...} Data unique to the component.
ComponentArray.peak = function(self, entity)
    return self.entities[entity]
end

--- Destroy the component data of the given entity.
-- @tparam ComponentArray self
-- @tparam int entity An entity's ID.
ComponentArray.remove = function(self, entity)
    self.entities[entity] = nil
end
    
--- Returns if the entity has component data in this ComponentArray.
-- @tparam ComponentArray self
-- @tparam int entity An entity's ID.
-- @treturn bool If the entity has this ComponentArray's component data.
ComponentArray.contains = function(self, entity)
    return self.entities[entity] ~= nil
end

return setmetatable(ComponentArray, {
    __call = function(...)
        return ComponentArray.new(...)
    end
})
