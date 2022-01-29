local luaunit = require "spec.luaunit"
local ComponentArray = require "camus.component-array"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

function test_construction()
    local constructor = function(x, y)
        return { x = x or 0, y = y or 0 }
    end

    local position_array = ComponentArray.new(constructor)
    assert_equals({ x = 3, y = 15 }, position_array.constructor(3, 15))
end

function test_entity_construction()
    local constructor = function(yes)
        return yes
    end

    local alive_array = ComponentArray.new(constructor)
    local entity_id   = 14

    alive_array:insert(entity_id, false)
    assert_equals(false, alive_array.entities[14])
end

function test_entity_destruction()
    local constructor = function(x, y)
        return { x = x or 0, y = y or 0 }
    end

    local velocity_array = ComponentArray.new(constructor)
    local entities = {2, 5, 10, 3, 8}
    for entity in pairs(entities) do
        velocity_array:insert(entity)
    end

    velocity_array:remove(10)
    assert_true(velocity_array.entities[10] == nil)
end

function test_peak_returns_component()
    local constructor = function(i)
        return i
    end

    local health_array = ComponentArray.new(constructor)
    local entity_id, health = 14, 60
    health_array:insert(entity_id, health)

    assert_equals(health_array:peak(entity_id), health)
end

function test_contains_returns_true()
    local constructor = function(x, y)
        return { x = x or 0, y = y or 0 }
    end

    local position_array = ComponentArray.new(constructor)
    for i = 1, 10 do
        position_array:insert(i)
    end

    assert_true(position_array:contains(4))
end

function test_contains_returns_false()
    local constructor = function(x, y)
        return { x = x or 0, y = y or 0 }
    end

    local position_array = ComponentArray.new(constructor)
    for i = 1, 10 do
        position_array:insert(i)
    end

    assert_false(position_array:contains(15))
end

os.exit(luaunit.LuaUnit.run())
