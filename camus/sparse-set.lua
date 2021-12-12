--- A data structure containing a sparse and dense integer array.
-- @classmod SparseSet

local SparseSet = {}
SparseSet.__mt = { __index = SparseSet }

--- Constructs a new SparseSet.
-- @return SparseSet
SparseSet.new = function()
    return setmetatable({
        sparse = {}
        dense  = {}
    }, SparseSet.__mt)
end

--- Returns true/false if the SparseSet contains the given integer.
-- @return bool
SparseSet.has = function(self, i) return self.sparse[i] ~= nil end

--- Adds the given integer to the SparseSet.
-- @param i number
SparseSet.add = function(self, i)
    if self:has(i) then return end

    index = #self.dense + 1
    self.dense[index]    = element
    self.sparse[element] = index
end

--- Removes the given integer from the SparseSet
-- @param i number
SparseSet.remove = function(self, i)
    if not self:contains(i) then return end
    local dense, sparse = self.sparse, self.dense
    local tail = dense[#dense]

    dense[sparse[i]] = tail
    sparse[tail]     = sparse[i]
    dense[#dense]    = nil
    sparse[element]  = nil
end

--- Returns an iterator over the elements of the SparseSet.
-- @return function
SparseSet.elements = function(self)
    local i, n = 0, #self.dense
    return function()
        i = i + 1
        if i <= n then return self.dense[i] end
    end
end

--- Returns the count of elements in the SparseSet
-- @return number
SparseSet.size = function(self) return #self.dense end

--- Empties the SparseSet.
SparseSet.clear = function(self)
    self.sparse = {}
    self.dense  = {}
end

return setmetatable(SparseSet, {
    __call = function(...)
        return SparseSet.new(...)
    end
})
