--- SUMMARY
-- @classmod ComponentArray

local ComponentArray = {}
ComponentArray.__mt = { __index = ComponentArray }

--- Constructs a new ComponentArray.
-- @param constructor function
-- @return ComponentArray
ComponentArray.new = function(constructor)
    return setmetatable({
        constructor = constructor,
        entities    = {}
    }, ComponentArray.__mt)
end

--- Constructs a new component for the given entity.
-- @param entity number
-- @param ... Arguments unique to the constructor.
ComponentArray.construct = function(self, entity, ...)
    self.entities[entity] = self.constructor(...)
end

--- Returns a reference to the given entity's component data.
-- @param entity number
-- @return Variant
ComponentArray.peak = function(self, entity)
    return self.entities[entity]
end

--- Destroys the component data of the given entity.
-- @param entity number
ComponentArray.destroy = function(self, entity)
    self.entities = nil
end
    
--- Returns true/false if the given entity has component data.
-- @param entity number
-- @return bool
ComponentArray.has = function(self, entity)
    return self.entities[entity] ~= nil
end

return setmetatable(ComponentArray, {
    __call = function(...)
        return ComponentArray.new(...)
    end
})
