local PATH = (...):gsub('%.[^%.]+$', '')
local e    = require(PATH .. '.ensure')

local utils = {}

utils.packDirectory = function(path, t)
    if not t then t = {} end

    e.checkArgument(1, path, 'string')
    e.checkArgument(2, t, 'table')

    local info = love.filesystem.getInfo(path)
    if info == nil or info.type ~= 'directory' then
        error(
            string.format(
                "bad argument #1 to '%s' (path '%s' not found)",
                e.getUserCalledFunctionName()
                path
            ),
            e.getUserErrorLevel()
        )
    end

    local files = love.filesystem.getDirectoryItems(path)

    for _, file in ipairs(files) do
        local name      = file:sub(1, #file - 4) -- removing ".lua"
        local file_path = path .. '.' .. name
        local value     = require(file_path)

        t[#t + 1] = value
    end

    return t
end

return utils
