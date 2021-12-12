--- SUMMARY
-- @classmod Context

local PATH = (...):gsub('%.[^%.]+$', '')
local e    = require(PATH .. '.ensure')

local SparseSet      = require(PATH .. '.sparse-set')
local EntityIndex    = require(PATH .. '.entity-index')
local ComponentArray = require(PATH .. '.component-array')
local System         = require(PATH .. '.system')
local Signature      = require(PATH .. 'signature')
local Filter         = require(PATH .. '.filter')

local Context = {}
Context.__mt = { __index = Context }

-- Constructs a new Context.
-- @return Context
Context.new = function()
    return setmetatable({
        entityIndex = EntityIndex.new(), 
        components  = {},                
        systems     = {},

        componentSets = {},              
        signatures    = {},              

        groups          = {},
        groupDictionary = {},

        dirty    = SparseSet.new(),
        toDelete = SparseSet.new(),
        
        component_count = 0
    }, Context.__mt)
end

local entityAlive = function(self, entity)
    if self.entityIndex:isAlive(entity) then
        return true
    else
        error(
            string.format(
                "bad entity #%i given in '%s' (entity does not exist)",
                entity,
                getUserCalledFunctionName()
            ),
            e.getUserErrorLevel()
        )
        return false
    end
end

--- Checks if the component is registered with the Context.
-- @param string component
local componentRegistered = function(self, component)
    if not self.components[component] then
        error(
            string.format(
                "bad component given in '%s' (component '%s' not registered with Context)",
                e.getUserCalledFunctionName(),
                component,
            ),
            e.getUserErrorLevel()
        )
        return false
    else return true end
end

--- Checks the type of the component and its elements.
-- @param table component
-- @return string The name of the component.
-- @return function The constructor of the component.
local validateComponent = function(component)
    local name, constructor = component[1], component[2]
    if type(name) ~= 'string' then
        error(
            string.format(
                "bad component given in '%s' (expected the name to be a string, got %s)",
                'registerComponent',
                type(name)
            ),
            e.getUserErrorLevel()
        )
    end

    if type(constructor) ~= 'function' then
        error(
            string.format(
                "bad component given in '%s' (expected the constructor to be a function, got %s)",
                'registerComponent',
                type(constructor)
            ),
            e.getUserErrorLevel()
        )
    end

    if self.components[name] then
        error(
            string.format(
                "bad component given in '%s' (component '%s' already registered with Context)",
                'registerComponent',
                'name'
            ),
            e.getUserErrorLevel
        )
    end

    return name, constructor
end

--- Registers the given component with the Context.
-- @param component table
Context.registerComponent = function(self, component)
    e.checkArgument(1, component, 'table')
    name, constructor = validateComponent(self, component)

    local id = #self.components + 1
    self.components[name]  = id 
    self.componentSets[id] = ComponentArray.new(constructor)
end

--- Registers multiple components with the Context.
-- @param t table
Context.registerComponents = function(self, t)
    e.checkArgument(1, t, 'table')
    for i = 1, #t do
        component = t[i]
        self:registerComponent(component)
    end
end

--- Registers the given System with the Context.
-- @param system System
Context.registerSystem = function(self, system)
    e.checkArgument(1, system, 'table')

    --[[
    -- Note that a System cannot operate by itself. It requires
    -- the Context to, at the very least, give it an initialized
    -- Filter--which itself needs to know what components are valid
    -- or not. That information is known only to the Context.
    --]]
    system.context = self
    system.filter = Filter.new(self.components, unpack(system.required))
    for entity in self:entities() do
        system:evaluate(entity, self.signatures[entity])
    end

    self.systems[#self.systems + 1] = system
end

--- Registers multiple Systems with the Context.
-- @param t table
Context.registerSystems = function(self, t)
    e.checkArgument(1, t, 'table')
    for i = 1, #t do self:registerSystem(t[i]) end
end

--- Registers a new entity and returns its ID.
-- @return number
Context.entity = function(self)
    local id = self.entityIndex:createEntity()
    self.signatures[id] = Signature.new()
    self:onEntityAdded(id)

    return id
end

--- Destroys the given entity.
-- Note that the entity "exists" until the next `:flush()` call.
-- @param entity number
Context.destroy = function(entity)
    if self.entityIndex:isAlive(entity) then
        self.toDelete:insert(entity)
    end
end

--- Evaluates and flushes changes to entities.
Context.flush = function(self)
    -- Check the relevent lists; if they're empty, nothing changed
    -- from the previous update so there's nothing to flush.
    if self.dirty:size() == 0 and self.toDelete:size() == 0 then return end

    local dirty, toDelete           = self.dirty, self.toDelete
    local componentSets, components = self.componentSets, self.components
    local systems, signatures       = self.systems, self.signatures
    local groups                    = self.groups

    -- For every entity the user queued for removal, remove from 
    -- their respective systems, groups, and componentArrays.
    for entity in toDelete:elements() do
        for i = 1, #systems do systems[i]:remove(entity) end
        for i = 1, #groups  do groups[i]:remove(entity)  end
        for i = 1, #componentSets do componentSets[i]:destroy(entity) end
        signatures[entity] = nil

        self.entityIndex:destroyEntity(entity)
        self:onEntityRemoved(entity)
    end

    toDelete:clear()

    -- For every entity the user modified, check if they 
    -- do or don't belong in any systems and groups.
    for entity in dirty:elements() do
        local signature = signatures[entity]
        for i = 1, #systems do systems[i]:evaluate(entity, signature) end
        for i = 1, #groups  do groups[i]:evaluate(entity, signature)  end
    end

    dirty:clear()
end

--- Gives the component to the entity.
-- @param entity number
-- @param component string
-- @param ... Component constructor arguments.
Context.give = function(self, entity, component, ...)
    e.checkArgument(1, entity, 'number')
    e.checkArgument(2, component, 'string')
    if entityAlive(entity) and componentRegistered(component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]

        signature:setComponent(component_id)
        self.dirty:insert(entity)
        self.componentSets[component_id]:constuct(entity, ...)
    end
end

--- Takes the component from the entity.
-- @param entity number
-- @param component string
Context.take = function(self, entity, component)
    e.checkArgument(1, entity, 'number')
    e.checkArgument(2, component, 'string')
    if entityAlive(entity) and componentRegistered(component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]

        signature:clearComponent(component_id)
        self.dirty:insert(entity)
        self.componentSets[component_id]:destroy(entity)
    end
end

--- Emits the specified event across all systems.
-- @param string event
Context.emit = function(self, event, ...)
    e.checkArgument(1, event, 'string')
    for i = 1, #self.systems do
        if not system:isEnabled()
        and system[event] and type(system[event] == 'function') then
            system[event](system, ...)
        end
    end
end

-- =======
-- QUERIES
-- =======

--- Checks if the given entity has the specified component.
-- @param number entity
-- @param string component
-- @return bool
Context.hasComponent = function(self, entity, component)
    if entityAlive(entity) and componentRegistered(component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]
        return signature:hasComponent(component_id)
    end
end

--- Returns the specified component data of the given entity.
-- @param number entity
-- @param string component
-- @param Variant
Context.getComponent = function(self, entity, component)
    if entityAlive(entity) and componentRegistered(component) then
        return self.componentsSets[self.components[component]]:peak(entity)
    end
end

--- Returns the data of the specified components of the given entity.
-- @param number entity
-- @param string ...
-- @return Variant
Context.getComponents = function(self, entity, ...)
    local components = {...}
    local res = {}
    if entityAlive(entity) then
        for i = 1, #components do
            if componentRegistered(components[i]) then
                res[i] = self.componentsSets[self.components[component]]:peak(entity)
            end
        end
    end

    return unpack(res)
end

--- Returns the specified group.
-- @param string name
-- @return System
Context.getGroup = function(self, name)
    e.checkArgument(1, name, 'string')
    if self.groupDictionary[name] then
        return self.groups[self.groupDictionary[name]]
    else
        error(
            string.format(
                "bad group '%s' in '%s' (group not registered)",
                name,
                e.getUserCalledFunctionName(),
            ),
            e.getUserErrorLevel()
        )
    end
end

--- Returns the total count of registered components.
-- @return number
Context.componentCount = function(self) return #self.components end

--- Returns the total count of registered Systems.
-- @return number
Context.systemCount = function(self) return #self.systems end

--- Returns the count of living entities.
-- @return number
Context.entityCount = function(self) return self.entityIndex.entities:size() end

-- =========================================================
-- ADVANCED QUERIES. ONLY USE IF YOU KNOW WHAT YOU'RE DOING.
-- ========================================================= 

--- Returns the numerical ID of the specified component.
-- @param component string
-- @return number
Context.getComponentID = function(self, component)
    e.checkArgument(1, component, 'string')
    if componentRegistered(self, component) then
        return self.components[component]
    end
end

--- Returns the ComponentArray of the specified component.
-- @param component string
-- @return ComponentArray
Context.getComponentArray = function(self, component)
    e.checkArgument(1, component, 'string')
    local id = self:getComponentID(component)
    return self.componentSets[id]
end

--- Returns the list of all registered components.
-- @return table
Context.getComponentList = function(self) return self.components end

--- Returns the Signature of the specified entity.
-- @param entity number
-- @return Signature
Context.getSignature = function(self, entity)
    if self.entityIndex:isAlive(entity) then
        return self.signatures[entity]
    else
        error(
            string.format(
                "bad entity #%i given in '%s' (entity does not exist)",
                entity,
                getUserCalledFunctionName()
            ),
            e.getUserErrorLevel()
        )
    end
end

--- Returns an iterator traversing all living entities.
-- @return function
Context.entities = function(self)
    local dense = self.entityIndex.entities.dense
    local i, n  = 0, #dense
    return function()
        i = i + 1
        if i <= n then return dense[i] end
    end
end

-- =========
-- UTILITIES
-- =========

--- Shortcut to creating and registering a new component.
-- @param name string Name of the new component.
-- @param constructor function Constructor of component data.
Context.createComponent = function(self, name, constructor)
    e.checkArgument(1, name, 'string')
    e.checkArgument(2, constructor, 'function')

    if self.componentSets[name] then
        error(
            string.format(
                "bad component given in '%s' (component '%s' already registered)",
                e.getUserCalledFunctionName(),
                name
            ),
            e.getUserErrorLevel()
        )
    else
        self:registerComponent( {name, constructor} )
    end
end

--- Shortcut to creating and registering a new System.
-- @param ... Components to exclusively process with the System.
Context.createSystem = function(self, ...)
    components = {...}
    for i = 1, #components do
        e.checkArgument(i, components[i], 'string')
    end

    system = System.new(...)
    self:registerSystem(system)
end

--- Creates a new group which selects for the given components.
-- @param name string Name of the group.
-- @param ... string Components to select for.
Context.createGroup = function(self, name, ...)
    e.checkArgument(1, name, 'string')

    if self.groupDictionary[name] then
        error(
            string.format(
                "bad group given in '%s' (group '%s' already registered)",
                e.getUserCalledFunctionName(),
                name
            ),
            e.getUserErrorLevel()
        )
    end

    local group = System.new(...)
    group.context = self
    group.filter  = Filter.new(self.components, unpack(group.required))
    for entity in self:entities() do
        group:evaluate(entity, self.signatures[entity])
    end

    local id = #self.groups + 1
    self.groups[id]            = group
    self.groupDictionary[name] = id
end

--- Removes everything from the Context, effectively making it new.
Context.clear = function(self)
    self.entityIndex = EntityIndex.new()
    self.components  = {}
    self.systems     = {}

    self.componentSets = {}
    self.signatures    = {}

    self.groups          = {}
    self.groupDictionary = {}

    self.toDelete = SparseSet.new()
    self.dirty    = SparseSet.new()
end

--- Callback for when an entity is added to the Context.
-- @param entity number
Context.onEntityAdded = function(self, entity)
end

--- Callback for when an entity is removed from the Context.
-- @param entity number
Context.onEntityRemoved = function(self, entity)
end

return setmetatable(Context, {
    __call = function(...)
        return Context.new(...)
    end
})
