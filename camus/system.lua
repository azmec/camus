--- Iterable collection of entities with a matching Signature.
-- @classmod System

local PATH      = (...):gsub('%.[^%.]+$', '')
local SparseSet = require(PATH .. '.sparse-set')

local System = {}
System.__mt = { __index = System }

local pack = function(...) return {...} end

--- Contructs a new System.
-- An interable collection of entities.
-- @param ... string Names of the components to match for.
-- @return System
System.new = function(...)
    return setmetatable({
        required = pack(...),
        pool     = SparseSet.new(),
        enabled  = true,

        -- These are filled in by the Context on registration.
        -- They're here as reminders; the System REQUIRES a
        -- Context to function properly.
        filter  = nil,
        context = nil
    }, System.__mt)
end

--- Closured iterator which returns the next entity in the list.
-- @return function
System.entities = function(self)
    local pool    = self.pool
    local i, size = 0, pool:size()
    return function()
        i = i + 1
        if i <= size then return pool.dense[i] end
    end
end

--- Check if the given entity should be within the System.
-- Note that this method is THE way to add entities.
-- If the entity's signature matches the System's, it's added
-- if not already in it; if it doesn't, it's removed if in the
-- System.
-- @param entity number Entity to evaluate
-- @param signature table Signature of the entity.
System.evaluate = function(self, entity, signature)
    local filter, pool = self.filter, self.pool
    local in_pool      = pool:contains(entity)
    local is_match     = filter:match(signature)
    
    if not in_pool and not is_match then
        return
    elseif not in_pool and is_match then
        pool:insert(entity)
        self:onEntityAdded(entity)
    elseif not is_match and in_pool then
        pool:remove(entity)
        self:onEntityRemove(entity)
    end
end

--- Returns the specified component of the given entity.
-- @param number entity
-- @param string component
-- @return Variant
System.getComponent = function(self, entity, component)
    return self.context:getComponent(entity, component)
end

--- Removes the given entity from the System.
-- @param entity number Entity to evaluate.
System.remove = function(self, entity)
    self.pool:remove(entity)
end

--- Set if the System is processing or not.
-- @value bool value
System.setEnabled = function(self, value) self.enabled = value end

--- Return if the System is enabled.
-- @return bool
System.isEnabled = function(self) return self.enabled end

--- Returns the names of the System's required components.
-- @return table List of the required components names.
System.getRequired = function(self) return self.required end

--- Callback for when the System is added to the Context.
-- @param Context context
System.init = function(self, context)
end

--- Callback for when the System is enabled.
System.onEnabled = function(self)
end

--- Callback for when the System is disabled.
System.onDisabled = function(self)
end

--- Callback for whenever an entity is added to the system.
-- @param entity number The added entity.
System.onEntityAdded  = function(self, entity) end

--- Callback for whenever an entity is removed from the system.
-- @param entity number The removed entity.
System.onEntityRemoved= function(self, entity) end

return setmetatable(System, {
    __call = function(_, ...)
        return System.new(...)
    end
})
