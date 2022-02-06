local luaunit = require "spec.luaunit"
local EntityIndex = require "camus.entity-index"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

function test_create_entity()
    local index = EntityIndex()
    for i = 1, 10 do
        index:createEntity()
    end

    assert_equals(11, index:createEntity())
end

function test_recycle_id()
    local index = EntityIndex()
    for i = 1, 10 do
        index:createEntity()
    end

    -- Destory the topmost entity
    index:destroyEntity(10)

    -- Recycle the identity of the topmost entity
    assert_equals(index:createEntity(), 10)
end

function test_entity_alive()
    local index = EntityIndex()
    for i = 1, 10 do
        index:createEntity()
    end

    index:destroyEntity(5)
    assert_false(index:isAlive(5))
end

function test_living()
    local index = EntityIndex()
    for i = 1,  50 do index:createEntity()  end
    for i = 10, 24 do index:destroyEntity(i) end

    assert_equals(index.living, 35)
end

os.exit(luaunit.LuaUnit.run())
