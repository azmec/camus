--- Iterable collection of entities.
-- @classmod System

local PATH      = (...):gsub('%.[^%.]+$', '')
local SparseSet = require(PATH .. '.sparse-set')

local System = {}
System.__mt = { __index = System }

local pack = function(...) return {...} end

--- Contruct a new System.
-- @tparam string ... Names of the components to match for.
-- @treturn System
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

--- Return an iterator over the System's entities.
-- @tparam System self
-- @treturn func Iterator over the System's entities.
System.entities = function(self)
    local pool    = self.pool
    local i, size = 0, pool:size()
    return function()
        i = i + 1
        if i <= size then return pool.dense[i] end
    end
end

--- Return if the given entity should be within the System.
-- Note that this method proxies as a way to add entities. If the entity's
-- signature matches that of the System's, it is added to the System; if 
-- the entity is already in the system and no longer matches, it's removed.
-- @tparam System self
-- @tparam int entity Entity to evaluate
-- @tparam tab signature Signature of the entity.
System.evaluate = function(self, entity, signature)
    local filter, pool = self.filter, self.pool
    local in_pool      = pool:has(entity)
    local is_match     = filter:match(signature)
    
    if not in_pool and not is_match then
        return
    elseif not in_pool and is_match then
        pool:add(entity)
        self:onEntityAdded(entity)
    elseif not is_match and in_pool then
        pool:remove(entity)
        self:onEntityRemove(entity)
    end
end

--- Return the specified component of the entity.
-- @tparam System self
-- @tparam int entity The entity's ID.
-- @tparam string component String identifier for the component.
-- @treturn ... Data unique to the component.
System.getComponent = function(self, entity, component)
    return self.context:getComponent(entity, component)
end

--- Remove the entity from the System.
-- @tparam System self
-- @tparam number entity The entity's ID.
System.remove = function(self, entity)
    self.pool:remove(entity)
end

--- Set if the System is processing.
-- @tparam System self
-- @tparam bool value If the System should be processing.
System.setEnabled = function(self, value) self.enabled = value end

--- Return if the System is processing.
-- @tparam System self
-- @treturn bool If the System is processing.
System.isEnabled = function(self) return self.enabled end

--- Returns the names of the System's required components.
-- @tparam System self
-- @treturn {string, ...} Table of the required components' identifiers.
System.getRequired = function(self) return self.required end

--- Callback for when the System is added to the Context.
-- @tparam System self
-- @tparam Context context Context to which the System was added to.
System.init = function(self, context)
end

--- Callback for when the System is enabled.
-- @tparam System self
System.onEnabled = function(self)
end

--- Callback for when the System is disabled.
-- @tparam System self
System.onDisabled = function(self)
end

--- Callback for whenever an entity is added to the System.
-- @tparam System self
-- @tparam entity number The added entity's ID.
System.onEntityAdded  = function(self, entity) end

--- Callback for whenever an entity is removed from the System.
-- @tparam System self
-- @tparam entity number The removed entity's ID.
System.onEntityRemoved= function(self, entity) end

return setmetatable(System, {
    __call = function(_, ...)
        return System.new(...)
    end
})
