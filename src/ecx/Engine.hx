package ecx;

import ecx.types.TypeInfo;
import ecx.ds.CArray;
import ecx.managers.EntityManager;
import ecx.types.TypeManager;
import haxe.macro.Context;
import haxe.macro.Expr;

@:unreflective
@:final
@:access(ecx.World)
class Engine {

	public static var instance(default, null):Engine;

	// type id => entity id => component obj
	public var components(default, null):CArray<CArray<Component>>;

	// entity id => entity obj
	public var mapToEntity(default, null):CArray<Entity>;

	// entity id => world
	public var worlds(default, null):CArray<World>;
	// world id => world
	public var mapToWorld(default, null):CArray<World>;

	public var worldsTotal(default, null):Int = 0;
	public var entityManager(default, null):EntityManager;
	var _types:TypeManager;

	function new(capacity:Int, worldsMaxCount:Int = 1) {
		_types = new TypeManager();
		mapToWorld = new CArray(worldsMaxCount);
		components = new CArray(_types.nextComponentId);
		for(i in 0...components.length) {
			components[i] = new CArray(capacity);
		}

		entityManager = new EntityManager(this, capacity);
		mapToEntity = entityManager.map;
		worlds = entityManager.worlds;
	}

	public static function initialize(capacity:Int = 0x40000):Engine {
		if(instance != null) {
			throw "Engine already created";
		}
		instance = new Engine(capacity);
		return instance;
	}

	public function createWorld(config:WorldConfig):World {
		if(worldsTotal >= mapToWorld.length) throw 'Max world count is ${mapToWorld.length}';
		return new World(worldsTotal++, this, config);
	}

	@:nonVirtual @:unreflective
	public function createPrefab():Entity {
		// TODO: delete prefabs!!!
		return mapToEntity[entityManager.alloc()];
	}

	macro static public function typeId<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
		return macro @:pos(haxe.macro.Context.currentPos())$type._TYPE_ID;
	}

	macro public static function typeIndex<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
		return macro @:pos(haxe.macro.Context.currentPos())$type._TYPE_INDEX;
	}

	inline public function typeInfo<T>(type:Class<T>):Null<TypeInfo> {
		return _types.lookup.get(Type.getClassName(type));
	}

	macro public function mapTo<T:Component>(self:ExprOf<Engine>, type:ExprOf<Class<T>>):ExprOf<MapTo<T>> {
		return macro new MapTo(cast $self.components[$type._TYPE_ID]);
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