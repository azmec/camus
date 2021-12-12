camus
=====
`camus` is an **E**ntity **C**ompoent **S**ystem (ECS) written in 
[Lua](www.lua.org)--primarily for the [LÖVE](https://love2d.org) 
game framework. 

installation
------------
Download the `camus` folder and chuck that into your project. Like
all other Lua modules, require it like so:

```lua
local camus = require('path.to.camus')
```

Lifting from other ECSs within the LÖVE ecosystem, you can either
"globalize" or individual require the modules within `camus` too:

```lua
local camus = require('path.to.camus')
camus.globalize()

-- Normally, you'd call `camus.System.new()`.
local moveSystem = System.new("position", "velocity")
```

```lua
local camus = require('path.to.camus')

local System      = camus.System
local Context     = camus.Context
local EntityIndex = camus.EntityIndex
```

documentation
-------------
Documentation can be found [here](https://www.aldats.dev/camus).

testing
-------
`camus` can be tested using [busted](https://olivinelabs.com/busted).

other resources
---------------
This project was born from wanting to learn how to make an ECS and
having some gripes with others already in the LÖVE ecosystem. These 
gripes are lazy, petty, and not actually worth rolling your own.
Please, take a look and these highly functional and practical libraries:

- [Concord](https://github.com/Tjakka5/Concord)
- [nata](https://github.com/tesselode/nata)
- [lovetoys](https://github.com/lovetoys/lovetoys)
- [tiny-ecs](https://github.com/bakpakin/tiny-ecs)

license
-------
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
