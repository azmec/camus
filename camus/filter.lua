--- Interface containing a Signature and ability to "match" it with others.
-- This class is intended to be handled exclusively by the Context and not 
-- by any users. However, using it outside "that context" can be trivial.
-- Filters require a list of *known* or *valid* components to check 
-- against, and this list can be obtained through the Context's
-- `getComponentList()` method.
-- @classmod Filter

local PATH      = (...):gsub('%.[^%.]+$', '')
local Signature = require(PATH .. '.signature')

local pack = function(...) return { ... } end

local Filter = {}
Filter.__mt = { __index = Filter }

--- Construct a new Filter.
-- @tparam tab components String-indexed dictionary of component IDs.
-- @tparam string ... Components to generate a Signature from.
-- @see Context:getComponentList
-- @treturn Filter
Filter.new = function(components, ...)
    local required, ids = {...}, {}
    for i = 1, #required do
        local id = components[required[i]]
        if id ~= nil then ids[i] = id end
    end

    local signature = Signature.new()
    signature:setComponents(unpack(ids))

    return setmetatable({
        signature = signature
    }, Filter.__mt)
end

-- TODO: Be more specific about the matching relationship.
--- Return if the other Signature matches Filter's.
-- @tparam Filter self
-- @tparam Signature other The Signature to match against.
-- @treturn bool If the other Signature matches the Filter's.
Filter.match = function(self, other)
    return self.signature:isSubsetOf(other)
end

-- FIXME:
-- Attempting to construct a filter with `Filter()` and using arguments
-- makes the first argument of `new()` be `self` instead of `components`
return setmetatable(Filter, {
    __call = function(...)
        return Filter.new(...)
    end
})
