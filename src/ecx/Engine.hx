package ecx;

import ecx.types.TypeManager;

/**
	Engine store global data about types and manage world's allocation
**/
@:unreflective
@:final
@:access(ecx.World)
class Engine {

	/**
		Types information
	**/
	public static var types(get, never):TypeManager;

	/**
		Total worlds allocated
	**/
	public static var worldsTotal(get, never):Int;

	/**
		Create new world
	**/
	public static function createWorld(config:WorldConfig, capacity:Int = 0x10000):World {
		var world = new World(_worlds.length, config, capacity);
		_worlds[world.id] = world;
		return world;
	}

	/**
		Get world by index
	**/
	inline public static function getWorld(index:Int):World {
		return _worlds[index];
	}

	static var _worlds:Array<World> = [];
	static var _types:TypeManager;

	inline static function get_worldsTotal() {
		return _worlds.length;
	}

	inline static function get_types() {
		if(_types == null) {
			_types = new TypeManager();
		}
		return _types;
	}
}