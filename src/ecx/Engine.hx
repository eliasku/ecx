package ecx;

import ecx.types.TypeInfo;
import ecx.ds.CArray;
import ecx.types.TypeManager;

@:unreflective
@:final
@:access(ecx.World)
class Engine {

	public static var instance(default, null):Engine;

	public var worldsTotal(default, null):Int = 0;

	// world id => world
	var _worlds:CArray<World>;

	var _types:TypeManager;

	function new(worldsMaxCount:Int) {
		_types = new TypeManager();
		_worlds = new CArray(worldsMaxCount);
	}

	public static function initialize(worldsMaxCount:Int = 1):Engine {
		if(instance != null) {
			throw "Engine already created";
		}
		instance = new Engine(worldsMaxCount);
		return instance;
	}

	public function createWorld(config:WorldConfig, capacity:Int = 0x40000):World {
		if(worldsTotal >= _worlds.length) throw 'Max world count is ${_worlds.length}';
		var world = new World(worldsTotal++, this, config, capacity);
		_worlds[world.id] = world;
		return world;
	}

	inline public function typeInfo<T>(typeClass:Class<T>):Null<TypeInfo> {
		return _types.lookup.get(Type.getClassName(typeClass));
	}

	inline public function getComponentTypesCount():Int {
		return _types.componentsNextTypeId;
	}

	inline public function getWorld(index:Int):World {
		return _worlds[index];
	}

	public function toString() {
		return "Engine";
	}
}