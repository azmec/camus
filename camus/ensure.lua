-- It should be worth noting I've ripped ALL of these from
-- https://github.com/tesselode/nata/blob/nata.lua.
-- It's good stuff.

--- Gets the error level need to make an error appear in the
-- user's code rather than the library's code.
-- @return number
local getUserErrorLevel = function()
    local source = debug.getinfo(1).source
    local level  = 1
    while debug.getinfo(level).source == source do
        level = level + 1
    end
    --[[
    -- We return `level - 1` here instead of `level` because
    -- the level was calculated one function deeper than the
    -- the function that will actually use this value. If we
    -- produced an error *inside* this function, `level` 
    -- would be correct, but for the function calling this 
    -- function, `level - 1` is correct.
    --]]
    return level - 1
end

--- Gets the name of the function that the user called that
-- eventually caused the error.
-- @return string
local getUserCalledFunctionName = function()
    return debug.getinfo(getUserErrorLevel() - 1).name
end

--- Checks the given condition and errors out if it's false.
local checkCondition = function(condition, message)
    if condition then return end
    error(message, getUserErrorLevel())
end

--- Changes a list of types into a human-readable phrase.
-- i.e. `string, table, number` -> "string, table, or number"
local getAllowedTypesText = function(...)
    local numberOfArguments = select('#', ...)
    if numberOfArguments >= 3 then
        local text = ''
        for i = 1, numberOfArguments - 1 do
            text = text .. string.format('%s', select(i, ...))
        end

        text = text .. string.format('or %s', select(numberOfArguments, ...))
        return text
    elseif numberOfArguments == 2 then
        return string.format('%s or %s', select(1, ...), select(2, ...))
    end

    return select(1, ...)
end

--- Checks if an argument is of the correct type and, if not,
-- throws a "bad argument" error consistent with the ones Lua
-- and LÖVE produce.
local checkArgument = function(argument_index, argument, ...)
    for i = 1, select('#', ...) do
        -- Allow tables with the `__call` metamethod to be treated
        -- like functions.
        if select(i, ...) == 'function' 
        and type(argument) == 'table'
        and getmetatable(argument).__call then
            return
        end

        if type(argument) == select(i, ...) then return end
    end

    error(
        string.format(
            "bad argument #%i to '%s' (expected %s, got %s)",
            argument_index
            getUserCalledFunctionName(),
            getAllowedTypesText(...),
            type(argument)
        ),
        getUserErrorLevel()
    )
end

local checkOptionalArgument = function(argument_index, argument, ...)
    if argument == nil then return end
    checkArgument(argument_index, argument, ...)
end

local ensure = {}
ensure.getUserErrorLevel         = getUserErrorLevel
ensure.getUserCalledFunctionName = getUserCalledFunctionName
ensure.checkArgument             = checkArgument
ensure.checkOptionalArgument     = checkOptionalArgument

return ensure
