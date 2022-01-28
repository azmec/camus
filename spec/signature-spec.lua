local luaunit = require "spec.luaunit"
local Signature = require "camus.signature"

local run = luaunit.LuaUnit.run
local assert_equals = luaunit.assertEquals
local assert_true = luaunit.assertTrue
local assert_false = luaunit.assertFalse

local test = {}

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

os.exit(run())
