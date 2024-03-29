--- Structure mainting a list of all living and destroyed entities.
-- @classmod EntityIndex

local PATH      = (...):gsub('%.[^%.]+$', '')
local SparseSet = require(PATH .. '.sparse-set')
local Stack     = require(PATH .. '.stack')

local EntityIndex = {}
EntityIndex.__mt = { __index = EntityIndex }

--- Construct an EntityIndex.
-- @treturn EntityIndex
EntityIndex.new = function()
    return setmetatable({
        entities  = SparseSet.new(),
        destroyed = Stack.new(),
        living    = 0
    }, EntityIndex.__mt)
end

--- Return if the entity is in the EntityIndex.
-- @tparam EntityIndex self
-- @tparam int entity An entity's ID. 
-- @treturn bool If the entity is in the EntityIndex.
EntityIndex.isAlive = function(self, entity)
    return self.entities:contains(entity)
end

--- Create a new entity and return its ID.
-- Note that the ID could be the same as a previously destroyed
-- entity, as the EntityIndex recycles past IDs.
-- @tparam EntityIndex self
-- @treturn int The entity's ID.
EntityIndex.createEntity = function(self)
    local id = nil
    -- Recycle the ID of the most recently destroyed 
    -- entity, if available.
    if self.destroyed:size() > 0 then
        id = self.destroyed:pop()
    else
        id = self.living + 1 
    end

    self.entities:insert(id)
    self.living = id

    return id
end

--- Remove the entity from the EntityIndex.
-- @tparam EntityIndex self
-- @tparam int entity An entity's ID.
EntityIndex.destroyEntity = function(self, entity)
    if self.living <= 0 or not self.entities:contains(entity) then 
        return 
    end

    self.entities:remove(entity)
    self.destroyed:push(entity)

    self.living = self.living - 1
end

return setmetatable(EntityIndex, {
    __call = function(...)
        return EntityIndex.new(...)
    end
})
