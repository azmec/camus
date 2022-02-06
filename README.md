camus
=====
An absurd Entity Component System for LÖVE.

Table of Contents
=================
1. [About](#About)
2. [Installation](#Installation)
6. [Other Resources](#Other-Resources)
    1. [LÖVE[ly] Entity Component Systems](#lovely-ecs)
    2. [On Entity Component Systems](#on-entity-component-systems)

About <a name="About"></a>
-----
`camus` is a [Lua][A0] module for the [LÖVE][A1] game framework, and it 
lets you write simple, performant, and manageable game logic through the 
Entity Component System (ECS) paradigm. To be precise, `camus` is
*targeted* at LÖVE and its version of [LuaJIT][A2]. `camus` is capable of
working outside of this environment with modifications--though it is not
tested outside of this environment.

[A0]: https://www.lua.org
[A1]: https://love2d.org
[A2]: https://luajit.org/luajit.html

Installation <a name="Installation"></a>
------------
To use `camus` in your project, drop the `camus/` folder into your location
of choice and require it like so:

```lua
local camus = require "path.to.camus"

local Context = camus.Context
local System  = camus.System
```

Additionally, `camus` unashamedly borrows from other ECSs within the LÖVE 
ecosystem and provides convenient namespace functions:

```lua
local camus = require "path.to.camus"
camus.globalize()

-- camus' modules, Context, System, ComponentArray, and so on, are now
-- accessible in the global namespace!

local context = Context()
```

Other Resources <a name="Other-Resources"></a>
---------------
### LÖVE[ly] Entity Component Systems <a name="lovely-ecs"></a>
This project was born from wanting to learn how to make an ECS and
having some gripes with others already in the LÖVE ecosystem. These 
gripes are lazy, petty, and not actually worth rolling your own.
While `camus` is performant and pleasing to use, the following modules are
(1) mature and (2) may better fit your particular use-case.

- [Concord](https://github.com/Tjakka5/Concord): A feature-complete ECS
  library
- [nata](https://github.com/tesselode/nata): Entity management for Lua.
- [lovetoys](https://github.com/lovetoys/lovetoys): A full-featured
  Entity-Component-System framework for making games with Lua.
- [tiny-ecs](https://github.com/bakpakin/tiny-ecs): ECS for Lua.

### On Entity Component Systems <a name="on-entity-component-systems"></a>
The following are resources I consulted or encountered in the course of
making this module. These are the time-tested pages who have an excessive
count of backlinks throughout the Web and novel pages who provide unique
insights.

- [Concord](https://github.com/Tjakka5/Concord): Tjakka5 provides a brief
  introduction into ECSs in the `README.md` of his project page. It is
  concise, and it provides everything you need to know if you are quick to
  get your hands dirty.
- [Wikipedia](https://en.wikipedia.org/wiki/Entity_component_system): If
  encyclopedic prose is your preference, the Wikipedia page provides a
  history, description, and tangential information concerning ECSs.
- [Sander Mertens' ECS FAQ](https://github.com/SanderMertens/ecs-faq):
  Mertens not only presents an extensive FAQ answering common questions,
  but also provides selected resources to understand ECSs and their
  motivations.
- [ECS Back and Forth: Part 2](https://skypjack.github.io/2019-03-07-ecs-baf-part-2/):
  Michele "skypjack" Caini introduces readers to entity management in ECSs
  and the two dominant approaches.
- [ECS Back and Forth: Part 3](https://skypjack.github.io/2019-05-06-ecs-baf-part-3/):
  Caini discusses the necessity of recycling entity identifiers and his
  approach to the problem.
- [ECS Back and Forth: Part 9](https://skypjack.github.io/2020-08-02-ecs-baf-part-9/):
  Caini describes the "sparse set" data structure and 
  its applications to ECSs.
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/dodmain.html):
  The selected chapters of the paid, physical version of *Data Oriented
  Design* by Richard Fabian. This is beyond excessive if you're looking to
  *just* create a minimal ECS, but it incredibly useful if you look to
  develop more mature frameworks and work with similar data structures in
  other projects.

