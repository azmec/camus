--- Object to quickly generate and match Signatures based
-- on given components.
-- @classmod Filter

local PATH      = (...):gsub('%.[^%.]+$', '')
local Signature = require(PATH .. '.signature')

-- If unit testing with `busted`, comment function
-- delcaration out and localization in.
local pack = function(...) return { ... } end
--local pack = table.pack

local Filter = {}
Filter.__mt = { __index = Filter }

--- Constructs a new Filter.
-- @param components table Array of valid compnent IDs.
-- @param ... string Components to filter for.
-- @see Context:getComponentList
-- @return Filter
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

--- Checks if the given Signature matches that of the Filter.
-- @param other Signature
-- @return bool
Filter.match = function(self, other)
    return self.signature:isSubsetOf(other)
end

return setmetatable(Filter, {
    __call = function(...)
        return Filter.new(...)
    end
})
