---
-- @module camus

local PATH = (...):gsub('%.init$', '')

local camus = {
    _VERSION     = "0.3",
    _DESCRIPTION = "An absurd ECS library for LÖVE.",
    _LICENSE     = [[
        MIT LICENSE

        Copyright (c) 2021 aldats

        Permission is hereby granted, free of charge, to any person 
        obtaining a copy of this software and associated documentation 
        files (the "Software"), to deal in the Software without 
        restriction, including without limitation the rights to use, 
        copy, modify, merge, publish, distribute, sublicense, and/or 
        sell copies of the Software, and to permit persons to whom the 
        Software is furnished to do so, subject to the following 
        conditions:

        The above copyright notice and this permission notice shall be
        included in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
        EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
        OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
        NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
        HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
        WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
        FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
        OTHER DEALINGS IN THE SOFTWARE.
    ]]
}

local populateNamespace = function(namespace)
    namespace.SparseSet      = require(PATH .. '.sparse-set')
    namespace.Stack          = require(PATH .. '.stack')
    namespace.EntityIndex    = require(PATH .. '.entity-index')
    namespace.ComponentArray = require(PATH .. '.component-array')
    namespace.System         = require(PATH .. '.system')
    namespace.Context        = require(PATH .. '.context')
    namespace.Utils          = require(PATH .. '.utils')
end

camus.globalize = function()
    populateNamespace(_G)
end

populateNamespace(camus)
return camus
