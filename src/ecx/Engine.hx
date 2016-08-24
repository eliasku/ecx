package ecx;

import ecx.types.TypeInfo;
import ecx.types.TypeManager;

/**
	Engine store global data about types and manage world's allocation worlds
**/
@:unreflective
@:final
@:access(ecx.World)
class Engine {

	public static var instance(default, null):Engine;

	public var worldsTotal(get, never):Int;

	// world id => world
	var _worlds:Array<World> = [];

	var _types:TypeManager;

	function new() {
		_types = new TypeManager();
	}

	public static function initialize():Engine {
		if(instance != null) {
			throw "Engine already created";
		}
		instance = new Engine();
		return instance;
	}

	public function createWorld(config:WorldConfig, capacity:Int = 0x40000):World {
		var world = new World(_worlds.length, this, config, capacity);
		_worlds[world.id] = world;
		return world;
	}

//	inline public function typeInfo<T>(typeClass:Class<T>):Null<TypeInfo> {
//		return _types.lookup.get(Type.getClassName(typeClass));
//	}

	inline public function getComponentTypesCount():Int {
		return _types.componentsTotal;
	}

	inline public function getWorld(index:Int):World {
		return _worlds[index];
	}

	public function toString() {
		return "Engine";
	}

	inline function get_worldsTotal() {
		return _worlds.length;
	}
}