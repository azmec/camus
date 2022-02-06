local luaunit   = require "spec.luaunit"
local SparseSet = require "camus.sparse-set"

local assert_equals = luaunit.assertEquals
local assert_true   = luaunit.assertTrue
local assert_false  = luaunit.assertFalse

function test_insert_element_dense()
    local sparse_set = SparseSet()
    sparse_set:insert(4)

    assert_true(sparse_set.dense[1] == 4)
end

function test_insert_element_sparse()
    local sparse_set = SparseSet()
    sparse_set:insert(4)

    assert_true(sparse_set.sparse[4] == 1)
end

function test_contains_element()
    local sparse_set = SparseSet()
    for i = 1, 10 do
        sparse_set:insert(i)
    end

    sparse_set:remove(5)

    assert_false(sparse_set:contains(5))
end

function test_remove()
    local ss = SparseSet()
    for i = 1, 10 do ss:insert(i) end

    ss:remove(7)

    --[[
    -- Not exactly a "unit" test, but making sure the single "remove"
    -- operation works as intended requires making sure both table of
    -- the SparseSet contain the expected data.
    --]]
    expected_sparse = {1, 2, 3, 4, 5, 6, nil, 8, 9, 7}
    expected_dense  = {1, 2, 3, 4, 5, 6, 10, 8, 9}

    assert_equals(ss.dense, expected_dense)
    assert_equals(ss.sparse, expected_sparse)
end

function test_iterate_elements()
    local sparse_set = SparseSet()

    local expected_nums = {}
    for i = 1, 10 do
        expected_nums[i] = i
        sparse_set:insert(i)
    end
    
    local iterated_nums = {}
    for element in sparse_set:elements() do
        iterated_nums[element] = element
    end

    assert_equals(expected_nums, iterated_nums)
end

function test_size()
    local sparse_set = SparseSet()
    for i = 1, 25 do
        sparse_set:insert(i)
    end

    sparse_set:remove(20)

    assert_true(sparse_set:size() == 24)
end

function test_clear()
    local sparse_set = SparseSet()
    for i = 1, 25 do
        sparse_set:insert(i)
    end

    sparse_set:clear()
    assert_true(#sparse_set.sparse == 0 and #sparse_set.dense == 0)
end

os.exit(luaunit.LuaUnit.run())
