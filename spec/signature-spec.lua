local Signature = require 'camus.signature'

describe("CamusECS Signature Module", function()
    it("Can set individual components.", function()
        local signature = Signature.new()

        signature:setComponent(1) -- Should be a value of `2`
        assert.are.equal(2, signature[1])

        signature:setComponent(4) -- Should be a value of `18`
        assert.are.equal(18, signature[1])

        signature:setComponent(32) -- Second index should be `1`
        assert.are.equal(1, signature[2])
    end)
    it("Can clear individual components.", function()
        local signature = Signature.new()

        signature:setComponent(1)
        signature:setComponent(3)
        signature:setComponent(4)
        signature:setComponent(8)
        signature:setComponent(10)

        assert.are.equal(1306, signature[1])

        signature:clearComponent(8)

        assert.are.equal(1050, signature[1])

        signature:setComponent(45) -- 8192
        assert.are.equal(8192, signature[2])

        signature:clearComponent(45)
        assert.are.equal(0, signature[2])
    end)
    it("Can check for individual components.", function()
        local signature = Signature.new()

        signature:setComponent(1)
        signature:setComponent(3)
        signature:setComponent(4)
        signature:setComponent(8)
        signature:setComponent(10)
        signature:setComponent(45)

        assert.truthy(signature:hasComponent(1))
        assert.truthy(signature:hasComponent(3))
        assert.truthy(signature:hasComponent(4))
        assert.truthy(signature:hasComponent(8))
        assert.truthy(signature:hasComponent(10))
        assert.truthy(signature:hasComponent(45))

        assert.is_not.truthy(signature:hasComponent(0))
        assert.is_not.truthy(signature:hasComponent(2))
        assert.is_not.truthy(signature:hasComponent(5))
        assert.is_not.truthy(signature:hasComponent(6))
        assert.is_not.truthy(signature:hasComponent(7))
        assert.is_not.truthy(signature:hasComponent(9))
        assert.is_not.truthy(signature:hasComponent(32))
    end)
    it("Can check for subset matches.", function()
        local s1 = Signature.new()
        local s2 = Signature.new()

        s1:setComponents(1, 3, 4, 10, 32, 45)
        s2:setComponents(10, 32, 45)

        assert.truthy(s2:isSubsetOf(s1))
        assert.is_not.truthy(s1:isSubsetOf(s2))
    end)
end)
