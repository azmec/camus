local luaunit = require "spec.luaunit"
local Signature = require "camus.signature"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

function test_set_component()
    local signature = Signature()
    signature:setComponent(1)

    assert_equals(2, signature[1])
end

function test_clear_component()
    local signature = Signature()
    signature:setComponent(8)
    
    signature:clearComponent(8)

    assert_equals(0, signature[1])
end

function test_check_component()
    local signature = Signature()
    signature:setComponent(10)

    assert_true(signature:hasComponent(10))
end

function test_set_multiple_components()
    local s1, s2 = Signature(), Signature()
    s1:setComponents(1, 10, 5, 2, 23)
    s2:setComponent(1)
    s2:setComponent(10)
    s2:setComponent(5)
    s2:setComponent(2)
    s2:setComponent(23)

    assert_equals(s1, s2)
end

function test_subset_match()
    local s1, s2 = Signature(), Signature()
    s1:setComponents(1, 3, 4, 10, 32, 45)
    s2:setComponents(10, 32, 45)

    assert_true(s2:isSubsetOf(s1))
end

function test_not_subset_match()
    local s1, s2 = Signature(), Signature()
    s1:setComponents(1, 3, 4, 10, 32, 45)
    s2:setComponents(10, 32, 45)

    assert_false(s1:isSubsetOf(s2))
end

os.exit(luaunit.LuaUnit.run())
