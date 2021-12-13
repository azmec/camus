--- SUMMARY
-- @classmod EntityIndex

local PATH      = (...):gsub('%.[^%.]+$', '')
local SparseSet = require(PATH .. '.sparse-set')
local Stack     = require(PATH .. '.stack')

local EntityIndex = {}
EntityIndex.__mt = { __index = EntityIndex }

--- Constructs an EntityIndex.
-- @return EntityIndex
EntityIndex.new = function()
    return setmetatable({
        entities  = SparseSet.new(),
        destroyed = Stack.new(),
        living    = 0
    }, EntityIndex.__mt)
end

--- Returns true/false if the entity is in the EntityIndex.
-- @param entity number
-- @return bool
EntityIndex.isAlive = function(self, entity)
    return self.entities:has(entity)
end

--- Creates a new entity and returns its ID.
-- Note that the ID could be the same as a previously destroyed
-- entity, as the EntityIndex recycles past IDs.
-- @return number
EntityIndex.createEntity = function(self)
    local id = nil
    -- Recycle the ID of the most recently destroyed 
    -- entity, if available.
    if self.destroyed:size() > 0 then
        id = self.destroyed:pop()
    else
        id = self.living + 1 
    end

    self.entities:add(id)
    self.living = id

    return id
end

--- Removes the given entity from the EntityIndex.
-- @param entity number
EntityIndex.destroyEntity = function(self, entity)
    if self.living <= 0 or self.entities:has(entity) then return end

    self.entities:remove(entity)
    self.destroyed:push(entity)

    self.living = self.living - 1
end

return setmetatable(EntityIndex, {
    __call = function(...)
        return EntityIndex.new(...)
    end
})
