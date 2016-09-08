# ecx

[![Lang](https://img.shields.io/badge/language-haxe-orange.svg)](http://haxe.org)
[![Version](https://img.shields.io/badge/version-v0.1.0-green.svg)](https://github.com/eliasku/ecx)
[![Dependencies](https://img.shields.io/badge/dependencies-none-green.svg)](https://github.com/eliasku/ecx/blob/master/haxelib.json)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

[![Build Status](https://travis-ci.org/eliasku/ecx.svg?branch=master)](https://travis-ci.org/eliasku/ecx)
[![Build Status](https://ci.appveyor.com/api/projects/status/t0ql3d9hjp5f72jt?svg=true)](https://ci.appveyor.com/project/eliasku/ecx)

ECX is Entity Component System framework for Haxe

- [Asteroids Example](https://github.com/eliasku/ecx-richardlord-asteroids)
- [Documentation](https://eliasku.github.io/ecx/api-minimal)
- [Benchmarks](https://github.com/eliasku/ecx-benchmarks)

Libraries (work in progress):
- [ecx-common](https://github.com/eliasku/ecx-common): Common utilities
- [ecx-scene2d](https://github.com/eliasku/ecx-scene2d): Scene graph library example

## World

### Initialization

```
var config = new WorldConfig([...]);
var world = Engine.createWorld(config, ?capacity);
```

## Entity

Entity is just integer id value. `0` is reserved as invalid id.

## Service

All services are known at world creation. World provides possibility to resolve services. `World::resolve` use constant `Class<Service>` for resolving. At compile-time these expressions will be translated to lookup array access by constant index with unsafe cast (pseudo example: `cast _services[8]`). For `hxcpp` poiter trick is used to avoid generating `dynamic_cast`.

### Injection

Each service could have dependencies on different services. With `Wire<T:Service>` you could inject your dependencies to instance fields.

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

For all `System`
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

### System Flags

* `IDLE`: System doesn't override `update` method. Should not be updated.
* `CONFIG`: System is defined with `@:config` meta. This system is just configurator. It will be deleted after World initialization phase.

## Component

Component is a way to associate [data] per `Entity`. You could just use component-builders to define your own components.

```
class Position extends AutoComp<Point> {}

/// later just use it like Point class per entity
_position.get(entity).x = 10;
```

Or you could create any custom crazy ComponentStorage / ComponentManager.
```
class Color extends Service implements Component {
    // BitmapData is used just to demonstrate that you are not limited to anything to store <component data> per <entity>
    // Each pixel is color for entity
    var _colors:BitmapData;

    ...

    inline public function get(entity:Entity):Int {
        _colors.getPixel32(entity.id % _stride, Std.int(entity.id / _stride));
    }

    ....
}
```

**Injection:** World `Component` is `Service`, so you are able to invoke all messages directly to other services.
**Implementation:** `Component` is just interface, you could iterate all registered components and access their base API per entity. It's handy for automatically cloning or serialization.

## CTTI
`ServiceType`, `ServiceSpec`, `ComponentType`, `ClassMacroTools`

## RTTI
`TypeManager` (WIP)

## Debug

Use `-D ecx_debug` for debugging
Use `-D ecx_macro_debug` for macro debugging

## TODO:

- Rethink world initialization:
- - Are we are ok that instance of service could be created outside by default?
- Rethink system-flags
- Delete configurator services
- Add more information on specific cases of AutoComp<T>
- Pack<T> for dense storage
- Entity Generations
