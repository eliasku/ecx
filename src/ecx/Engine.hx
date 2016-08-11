package ecx;

import ecx.types.ComponentType;
import ecx.ds.Cast;
import ecx.types.TypeInfo;
import ecx.ds.CArray;
import ecx.types.TypeManager;
import haxe.macro.Expr;

@:unreflective
@:final
@:access(ecx.World)
class Engine {

	public static var instance(default, null):Engine;

	// world id => world
	public var mapToWorld(default, null):CArray<World>;
	public var worldsTotal(default, null):Int = 0;

	var _types:TypeManager;

	function new(worldsMaxCount:Int) {
		_types = new TypeManager();
		mapToWorld = new CArray(worldsMaxCount);
	}

	public static function initialize(worldsMaxCount:Int = 1):Engine {
		if(instance != null) {
			throw "Engine already created";
		}
		instance = new Engine(worldsMaxCount);
		return instance;
	}

	public function createWorld(config:WorldConfig, capacity:Int = 0x40000):World {
		if(worldsTotal >= mapToWorld.length) throw 'Max world count is ${mapToWorld.length}';
		var world = new World(worldsTotal++, this, config, capacity);
		mapToWorld[world.id] = world;
		return world;
	}

//	macro static public function typeId<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
//		return macro @:pos(haxe.macro.Context.currentPos())$type._TYPE_ID;
//	}
//
//	macro public static function specId<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
//		return macro @:pos(haxe.macro.Context.currentPos())$type._SPEC_ID;
//	}

	inline public function typeInfo<T>(typeClass:Class<T>):Null<TypeInfo> {
		return _types.lookup.get(Type.getClassName(typeClass));
	}

	public function toString() {
		return "Engine";
	}


	public static function calculateMemoryUsage(entityCapacity:Int, componentsCount:Int, families:Int) {
		var total = 0;

		// components storage
		total += componentsCount * 4 + (entityCapacity + 1) * 4;

		// entity pool
		total += entityCapacity * 4;

		// entity worlds map
		total += (entityCapacity + 1) * 4;

		// entity flags map
		total += (entityCapacity + 1) * 4;

		// entity id-wrapper map
		total += (entityCapacity + 1) * 4;

		// families active map storage
		total += families * (entityCapacity >>> 5);

		return total;
	}
}