--- Simple Last In First Out list implementation.
-- @classmod Stack

local Stack = {}
Stack.__mt = { __index = Stack }

--- Construct a new Stack.
-- @treturn Stack
Stack.new = function()
    return setmetatable({}, Stack.__mt)
end

--- Push an element onto the Stack.
-- @tparam ... i Element of any type.
Stack.push = function(self, i)
    self[#self + 1] = i
end

--- Pop the most recently pushed element off of the Stack.
Stack.pop = function(self)
    e = self[#self]
    self[#self] = nil
    return e
end

--- Return the count of elements in the Stack.
-- @treturn number Count of elements in the Stack.
Stack.size = function(self)
    return #self
end

return setmetatable(Stack, {
    __call = function(...)
        return Stack.new(...)
    end
})
