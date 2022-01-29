local luaunit = require "spec.luaunit"
local Stack   = require "camus.stack"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

function test_push()
    local stack = Stack()
    stack:push(3)

    assert_equals(3, stack[1])
end

function test_pop()
    local stack = Stack()
    stack:push(5)
    stack:push(1)
    stack:pop()

    assert_equals(5, stack[1])
end

function test_size()
    local stack = Stack()
    for i = 1, 10 do
        stack:push(i)
    end

    assert_equals(10, stack:size())
end

os.exit(luaunit.LuaUnit.run())
