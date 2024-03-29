--- A data structure containing a sparse and dense integer array.
-- @classmod SparseSet

local SparseSet = {}
SparseSet.__mt = { __index = SparseSet }

--- Construct a new SparseSet.
-- @treturn SparseSet
SparseSet.new = function()
    return setmetatable({
        sparse = {},
        dense  = {},
    }, SparseSet.__mt)
end

--- Return if the SparseSet contains the integer.
-- @tparam SparseSet self
-- @tparam int i
-- @treturn bool If the SparseSet contains the integer.
SparseSet.contains = function(self, i) return self.sparse[i] ~= nil end

--- Insert the integer into the SparseSet.
-- @tparam Signature self
-- @tparam int i 
SparseSet.insert = function(self, i)
    if self:contains(i) then return end

    local index = #self.dense + 1
    self.dense[index] = i
    self.sparse[i]    = index
end

--- Remove the integer from the SparseSet
-- @tparam Signature self
-- @tparam int i 
SparseSet.remove = function(self, i)
    if not self:contains(i) then return end

    local size  = #self.dense
    local index = self.sparse[i]
    local tail  = self.dense[size]

    self.dense[index] = tail  
    self.sparse[tail] = index 
    self.dense[size]  = nil

    -- Remove the pointing index in the sparse array
    self.sparse[i]    = nil
end

--- Return an iterator over the SpareSet's elements.
-- @tparam Signature self
-- @treturn func Iterator over the SparseSet's elements.
SparseSet.elements = function(self)
    local i, n = 0, #self.dense
    return function()
        i = i + 1
        if i <= n then return self.dense[i] end
    end
end

--- Return the count of elements in the SparseSet
-- @tparam Signature self
-- @treturn int Count of elements in the SparseSet.
SparseSet.size = function(self) return #self.dense end

--- Empty the SparseSet of its elements.
-- @tparam Signature self
SparseSet.clear = function(self)
    self.sparse = {}
    self.dense  = {}
end

return setmetatable(SparseSet, {
    __call = function(...)
        return SparseSet.new(...)
    end
})
