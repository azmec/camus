--- Psuedo-bitset implementation to generate Component signatures.
-- @classmod Signature

-- NOTE:
-- If unit testing with `busted`, change to "bit32."
local bit = require 'bit32'

local band, bor, bnot = bit.band, bit.bor, bit.bnot
local lshift, rshift  = bit.lshift, bit.rshift
local min, floor      = math.min, math.floor

-- NOTE:
-- If unit testing with `busted`, comment function
-- delcaration out and localization in.
local pack = function(...) return { ... } end
--local pack = table.pack

--[[
-- Note that the "bitset" behavior seen here isn't a real bitset.
-- Every signature is a sequential table containing a minimum of
-- one integer. We emulate bitset behavior by manipulating the bits
-- of that number, and we add another number to the table if we
-- need to access a component value greater than `NUM_BITS`.
-- Effectively, `NUM_BITS` is the amount of bits we assume the 
-- number to have until we consider it "full" and move on to the 
-- next number in the "bitset."
--]]
local NUM_BITS = 32

local Signature = {}
Signature.__mt = { __index = Signature }

--- Construct a new Signature.
-- @treturn Signature
Signature.new = function()
    return setmetatable({ 0 }, Signature.__mt)
end

--- Set the ith bit in the integer and return it.
-- @tparam int x 
-- @tparam int i 
-- @treturn int The given integer with the ith bit set.
local setBit = function(x, i) return bor(x, lshift(1, i)) end

--- Clear the ith bit in the integer and return it.
-- @tparam int x 
-- @tparam int i 
-- @treturn int The given integer with the ith bit cleared.
local clearBit = function(x, i) return band(x, bnot(lshift(1, i))) end

--- Return if the ith bit in the integer is set.
-- @tparam int x 
-- @tparam int i 
-- @treturn bool If the ith bit is set.
local bitIsSet = function(x, i) return band(rshift(x, i), 1) ~= 0 end

--- Set the component within the Signature.
-- @tparam Signature self
-- @tparam int i 
Signature.setComponent = function(self, i)
    local index = floor(i / NUM_BITS) + 1
    if index > #self then
        for i = #self + 1, index do self[i] = 0 end
    end

    i = i % NUM_BITS
    self[index] = setBit(self[index], i)
end

--- Clear the component within the Signature.
-- @tparam Signature self
-- @tparam int i 
Signature.clearComponent = function(self, i)
    local index = floor(i / NUM_BITS) + 1
    if index > #self then return end

    i = i % NUM_BITS
    self[index] = clearBit(self[index], i)
end

--- Return if the Signature has the component.
-- @tparam Signature self
-- @tparam int i 
-- @treturn bool If the Signature has the component.
Signature.hasComponent = function(self, i)
    local index = floor(i / NUM_BITS) + 1
    if index > #self then return false end

    i = i % NUM_BITS
    return bitIsSet(self[index], i)
end

--- Return if the Signature is a subset of the other.
-- @tparam Signature self
-- @tparam other Signature Signature to check if it is a "super" set.
-- @treturn bool If the Signature is a subset of the other.
Signature.isSubsetOf = function(self, other)
    local count = min(#self, #other)
    if #self > count then
        for i = count, #self do
            if self[i] ~= 0 then return false end
        end
    end

    for i = 1, count do
        local num = self[i]
        if band(num, other[i]) ~= num then return false end
    end

    return true
end

--- Set multiple components within the Signature.
-- @tparam Signature self
-- @tparam int ... Components to set.
Signature.setComponents = function(self, ...)
    local components = pack(...)
    for k = 1, #components do 
        --[[ NOTE:
        -- You may want to replace the below with the
        -- equivalent `setComponent` method--don't.
        -- It causes a stack overflow that I couldn't
        -- care to read the documentation to fix.
        --]]
        local i = components[k]
        local index = floor(i / NUM_BITS) + 1
        if index > #self then
            for i = #self + 1, index do self[i] = 0 end
        end

        i = i % NUM_BITS
        self[index] = setBit(self[index], i)
    end
end

return setmetatable(Signature, {
    __call = function(...)
        return Signature.new(...)
    end
})
