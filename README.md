# ecx

[![Lang](https://img.shields.io/badge/language-haxe-orange.svg)](http://haxe.org)
[![Version](https://img.shields.io/badge/version-v0.0.4-green.svg)](https://github.com/eliasku/ecx)
[![Dependencies](https://img.shields.io/badge/dependencies-none-green.svg)](https://github.com/eliasku/ecx/blob/master/haxelib.json)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

[![Build Status](https://travis-ci.org/eliasku/ecx.svg?branch=master)](https://travis-ci.org/eliasku/ecx)
[![Build Status](https://ci.appveyor.com/api/projects/status/t0ql3d9hjp5f72jt?svg=true)](https://ci.appveyor.com/project/eliasku/ecx)

ECX is Entity Component System framework for Haxe

- [Asteroids Example](https://github.com/eliasku/ecx-richardlord-asteroids)
- [Benchmarks](https://github.com/eliasku/ecx-benchmarks)

## System

### Injection

For example we need to inject TimeSystem system to our MovementSystem
```
class MovementSystem extends System {
    var _time:Wire<TimeSystem>;
    ...
    override function update() {
        var dt = _time.dt;
        ...
    }
}
```

### Family

For example we need to track all active(live) entities with components: Transform, Node and Renderable
```
class MovementSystem extends System {
    var _entities:Family<Transform, Node, Renderable>;
    ...
    override function update() {
        // Note: typeof _entities is Array<Entity>
        for(entity in _entities) {
            // only entities with required component will be displayed
            trace(entity.id);
        }
    }
}
```

### EntityView

EntityView is the utility class. It provides shortcut to edit entity using object-wrapper.

### System Flags

* `IDLE`: System doesn't override `update` method. Should not be updated.
* `CONFIG`: System is defined with `@:config` meta. This system is just configurator. It will be deleted after World initialization phase.
* `PROCESSOR`: System has at least one entity Family to process.

## Component

## World

### Initialization

```
var config = new WorldConfig([...]);
var world = Engine.initialize().createWorld(config, ?potCapacity);
```

## CTTI
`ClassMacroTools`

## RTTI
`TypeManager`

# TODO
* List of entities should be target-optimized `EntityVector`
* CBitArray target-optimized underlying data
* Examples
* Unit tests
* README
