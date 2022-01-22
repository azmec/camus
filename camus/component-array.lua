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
-- @tparam int entity An entity's ID.
-- @tparam {...} ... Arguments unique to the constructor.
ComponentArray.construct = function(self, entity, ...)
    self.entities[entity] = self.constructor(...)
end

--- Return the entity's component data.
-- @tparam int entity An entity's ID.
-- @treturn {...} Data unique to the component.
ComponentArray.peak = function(self, entity)
    return self.entities[entity]
end

--- Destroy the component data of the given entity.
-- @tparam int entity An entity's ID.
ComponentArray.destroy = function(self, entity)
    self.entities = nil
end
    
--- Returns if the entity has component data in this ComponentArray.
-- @tparam int entity An entity's ID.
-- @treturn bool If the entity has this ComponentArray's component data.
ComponentArray.has = function(self, entity)
    return self.entities[entity] ~= nil
end

return setmetatable(ComponentArray, {
    __call = function(...)
        return ComponentArray.new(...)
    end
})
