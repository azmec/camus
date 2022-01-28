camus
=====
`camus` is an Entity Compoent System (ECS) written in [Lua][A0] for the 
[LÖVE][A1] game framework. 

[A0]: www.lua.org
[A1]: https://love2d.org

Installation
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

Documentation
-------------
Documentation can be found [here](https://www.aldats.dev/camus).

Testing
-------
`camus` can be tested using [busted](https://olivinelabs.com/busted).

Other Resources
---------------
This project was born from wanting to learn how to make an ECS and
having some gripes with others already in the LÖVE ecosystem. These 
gripes are lazy, petty, and not actually worth rolling your own.
Please, take a look and these highly functional and practical libraries:

- [Concord](https://github.com/Tjakka5/Concord)
- [nata](https://github.com/tesselode/nata)
- [lovetoys](https://github.com/lovetoys/lovetoys)
- [tiny-ecs](https://github.com/bakpakin/tiny-ecs)
