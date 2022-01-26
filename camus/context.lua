--- SUMMARY
-- @classmod Context

local PATH = (...):gsub('%.[^%.]+$', '')
local e    = require(PATH .. '.ensure')

local SparseSet      = require(PATH .. '.sparse-set')
local EntityIndex    = require(PATH .. '.entity-index')
local ComponentArray = require(PATH .. '.component-array')
local System         = require(PATH .. '.system')
local Signature      = require(PATH .. '.signature')
local Filter         = require(PATH .. '.filter')

local Context = {}
Context.__mt = { __index = Context }

-- Construct a new Context.
-- @treturn Context
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

--- Return if the entity is alive.
-- @tparam Context self
-- @tparam int entity The entity's ID.
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

--- Return if the component is registered with the Context.
-- @tparam string component String identifier for the component.
local componentRegistered = function(self, component)
    if not self.components[component] then
        error(
            string.format(
                "bad component given in '%s' (component '%s' not registered with Context)",
                e.getUserCalledFunctionName(),
                component
            ),
            e.getUserErrorLevel()
        )
        return false
    else return true end
end

--- Checks the type of the component and its elements.
-- @tparam tab component
-- @treturn string The name of the component.
-- @treturn func The constructor of the component.
local validateComponent = function(self, component)
    local name, constructor = component[1], component[2]
    if type(name) ~= 'string' then
        error(
            string.format(
                "bad component given in '%s' (expected the name to be a string, got %s)",
                e.getUserCalledFunctionName(),
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

--- Register the component with the Context.
-- @tparam tab component The initializing component table.
Context.registerComponent = function(self, component)
    e.checkArgument(1, component, 'table')
    name, constructor = validateComponent(self, component)

    local id = #self.componentSets + 1
    self.components[name]  = id 
    self.componentSets[id] = ComponentArray.new(constructor)
end

--- Register multiple components with the Context.
-- @tparam {tab, ...} t Table of components to register.
Context.registerComponents = function(self, t)
    e.checkArgument(1, t, 'table')
    for i = 1, #t do
        component = t[i]
        self:registerComponent(component)
    end
end

--- Register the System with the Context.
-- @tparam System system System to register.
Context.registerSystem = function(self, system)
    e.checkArgument(1, system, 'table')

    --[[
    -- Note that a System cannot operate by itself. It requires
    -- the Context to, at the very least, give it an initialized
    -- Filter--which itself needs to know what components are valid
    -- or not. That information is known only to the Context.
    --]]
    system.context = self
    system.filter = Filter.new(self.components, system.required)
    for entity in self:entities() do
        system:evaluate(entity, self.signatures[entity])
    end

    self.systems[#self.systems + 1] = system
end

--- Register multiple Systems with the Context.
-- @tparam {System, ...} t Table of Systems to register.
Context.registerSystems = function(self, t)
    e.checkArgument(1, t, 'table')
    for i = 1, #t do 
        self:registerSystem(t[i]) 
    end
end

--- Register a new entity and returns its ID.
-- @treturn int The entity's ID.
Context.entity = function(self)
    local id = self.entityIndex:createEntity()
    self.signatures[id] = Signature.new()
    self:onEntityAdded(id)

    return id
end

--- Destroy the entity.
-- Note that the entity exists until the next `:flush()` call.
-- @tparam int entity The entity's ID.
Context.destroy = function(entity)
    if self.entityIndex:isAlive(entity) then
        self.toDelete:add(entity)
    end
end

--- Evaluate and flush changes to entities.
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

--- Give the specified component to the entity.
-- @tparam int entity The entity's ID.
-- @tparam string component The component's string identifier.
-- @tparam ... ... Contrusctor arguments unique to the component.
Context.give = function(self, entity, component, ...)
    e.checkArgument(1, entity, 'number')
    e.checkArgument(2, component, 'string')
    if entityAlive(self, entity) and componentRegistered(self, component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]

        signature:setComponent(component_id)
        self.dirty:add(entity)
        self.componentSets[component_id]:construct(entity, ...)
    end
end

--- Remove the specified component from the entity.
-- @tparam int entity The entity's ID.
-- @tparam string component The component's string identifier.
Context.take = function(self, entity, component)
    e.checkArgument(1, entity, 'number')
    e.checkArgument(2, component, 'string')
    if entityAlive(self, entity) and componentRegistered(self, component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]

        signature:clearComponent(component_id)
        self.dirty:add(entity)
        self.componentSets[component_id]:destroy(entity)
    end
end

--- Emit the specified event across all systems.
-- @tparam string event The event's string identifier.
Context.emit = function(self, event, ...)
    e.checkArgument(1, event, 'string')
    for i = 1, #self.systems do
        local system = self.systems[i]
        if system:isEnabled()
        and system[event] and type(system[event] == 'function') then
            system[event](system, ...)
        end
    end
end

-- =======
-- QUERIES
-- =======

--- Return if the entity has the specified component.
-- @tparam int entity The entity's ID.
-- @tparam string component The component's string identifier.
-- @treturn bool If the entity has the specified component.
Context.hasComponent = function(self, entity, component)
    if entityAlive(self, entity) and componentRegistered(self, component) then
        local component_id = self.components[component]
        local signature    = self.signatures[entity]
        return signature:hasComponent(component_id)
    end
end

--- Return the specified component data of the entity.
-- @tparam int entity The entity's ID.
-- @tparam string component The component's string identifier.
-- @tparam ... Data unique to the specified component.
Context.getComponent = function(self, entity, component)
    if entityAlive(self, entity) and componentRegistered(self, component) then
        return self.componentSets[self.components[component]]:peak(entity)
    end
end

--- Return the data of the specified components of the entity.
-- @tparam int entity The entity's ID.
-- @tparam string ... Loose list of components' string identifiers.
-- @treturn ... Data unique to the specified components.
Context.getComponents = function(self, entity, ...)
    local components = {...}
    local res = {}
    if entityAlive(self, entity) then
        for i = 1, #components do
            if componentRegistered(components[i]) then
                res[i] = self.componentsSets[self.components[component]]:peak(entity)
            end
        end
    end

    return unpack(res)
end

--- Return the specified group.
-- @tparam string name The group's string identifier.
-- @treturn System
Context.getGroup = function(self, name)
    e.checkArgument(1, name, 'string')
    if self.groupDictionary[name] then
        return self.groups[self.groupDictionary[name]]
    else
        error(
            string.format(
                "bad group '%s' in '%s' (group not registered)",
                name,
                e.getUserCalledFunctionName()
            ),
            e.getUserErrorLevel()
        )
    end
end

--- Return the total count of registered components.
-- @treturn int The count of registered components.
Context.componentCount = function(self) return #self.components end

--- Return the total count of registered Systems.
-- @treturn int The count of registered Systems.
Context.systemCount = function(self) return #self.systems end

--- Return the count of living entities.
-- @treturn int The count of living entities.
Context.entityCount = function(self) return self.entityIndex.entities:size() end

-- =========================================================
-- ADVANCED QUERIES. ONLY USE IF YOU KNOW WHAT YOU'RE DOING.
-- ========================================================= 

--- Return the integer ID of the specified component.
-- @tparam string component The component's string identifier.
-- @treturn int The integer ID of the specified component.
Context.getComponentID = function(self, component)
    e.checkArgument(1, component, 'string')
    if componentRegistered(self, component) then
        return self.components[component]
    end
end

--- Return the ComponentArray of the specified component.
-- @tparam string component The component's string identifier.
-- @treturn ComponentArray The ComponentArray of the specified component.
Context.getComponentArray = function(self, component)
    e.checkArgument(1, component, 'string')
    local id = self:getComponentID(component)
    return self.componentSets[id]
end

--- Return the list of all registered components' string identifiers.
-- @treturn {string, ...} List of registered components' string identifiers.
Context.getComponentList = function(self) return self.components end

--- Return the Signature of the entity.
-- @tparam int entity The entity's ID.
-- @treturn Signature The entity's Signature.
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

--- Return an iterator traversing all living entities.
-- @treturn func Iterator traversing all living entities.
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

--- Create and register a new component.
-- @tparam string name String identifier of the new component.
-- @tparam func constructor Constructor function returning component data.
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

--- Create and register a new System.
-- @tparam ... Loose list of component string identifiers to match for.
Context.createSystem = function(self, ...)
    components = {...}
    for i = 1, #components do
        e.checkArgument(i, components[i], 'string')
    end

    system = System.new(...)
    self:registerSystem(system)
end

--- Create a new group matching for the given components.
-- @tparam string name The group's string identifier.
-- @tparam string ... Loose list of component string identifiers to match for.
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

--- Remove everything from the Context, effectively making it "like new".
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
-- @tparam int entity The entity's ID. 
Context.onEntityAdded = function(self, entity)
end

--- Callback for when an entity is removed from the Context.
-- @tparam int entity The entity's ID.
Context.onEntityRemoved = function(self, entity)
end

return setmetatable(Context, {
    __call = function(...)
        return Context.new(...)
    end
})
