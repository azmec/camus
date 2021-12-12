--- Simple Last In First Out list implementation.
-- I already know; I like sugar.
-- @classmod Stack

local Stack = {}
Stack.__mt = { __index = Stack }

Stack.new = function()
    return setmetatable({}, Stack.__mt)
end

Stack.push = function(self, i)
    self[#self + 1] = i
end

Stack.pop = function(self, i)
    e = self[#self]
    self[#self] = nil
    return e
end

Stack.size = function(self)
    return #self
end

return setmetatable(Stack, {
    __call = function(...)
        return Stack.new(...)
    end
})
