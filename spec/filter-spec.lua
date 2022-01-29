local luaunit   = require "spec.luaunit"
local Filter    = require "camus.filter"
local Signature = require "camus.signature"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

local components = {}
components["position"] = 1
components["velocity"] = 2
components["sprite"]   = 3
components["health"]   = 4
components["input"]    = 5

function test_init()
    local filter = Filter.new(components, "position", "velocity")
    local signature = Signature()
    signature:setComponents(1, 2)

    assert_equals(filter.signature, signature)
end

function test_match_true()
    local filter = Filter.new(components, "position", "velocity")
    local entity_signature = Signature()
    entity_signature:setComponents(1, 2, 3, 4, 5)

    assert_true(filter:match(entity_signature))
end

function test_match_false()
    local filter = Filter.new(components, "position", "velocity")

    local entity_signature = Signature()
    entity_signature:setComponents(1, 3)

    assert_false(filter:match(entity_signature))
end

os.exit(luaunit.LuaUnit.run())
