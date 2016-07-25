package ecx;

import ecx.macro.WorldTypeBuilder;
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

	// TYPE -> ENTITIES
	public var components(default, null):CArray<CArray<Component>>;
	public var edb(default, null):EntityManager;
	public var entities(default, null):CArray<Entity>;
	public var worlds(default, null):CArray<World>;
	public var flags(default, null):CArray<Int>;

	var _types:TypeManager;

	function new(capacity:Int = 1000) {
		_types = new TypeManager();

		entities = new CArray(capacity + 1);
		worlds = new CArray(capacity + 1);
		flags = new CArray(capacity + 1);

		var componentsLength = _types.maxComponentId + 1;
		components = new CArray(componentsLength);
//		WorldTypeBuilder.createComponents(this, capacity);
		for(i in 0...componentsLength) {
			components[i] = new CArray(capacity + 1);
		}

		edb = new EntityManager(this, capacity);
	}

	public static function create(config:WorldConfig):World {
		if(instance == null) {
			instance = new Engine();
		}
		return new World(instance, config);
	}

	macro static public function typeId<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
		return macro @:pos(haxe.macro.Context.currentPos())$type._TYPE_ID;
	}

	macro public static function typeIndex<T>(type:ExprOf<Class<T>>):ExprOf<Int> {
		return macro @:pos(haxe.macro.Context.currentPos())$type._TYPE_INDEX;
	}

	inline public function getTypeIndex<T>(type:Class<T>):Int {
		//return TypeDb.lookup.get(Type.getClassName(type)).index;
		return 0;
	}

	inline public function getTypeId<T>(type:Class<T>):Int {
		//return TypeDb.lookup.get(Type.getClassName(type)).id;
		return 0;
	}

	inline public function getTypeKind<T>(type:Class<T>):Int {
		//return TypeDb.lookup.get(Type.getClassName(type)).kind;
		return 0;
	}

	macro public function mapTo<T:Component>(self:ExprOf<Engine>, type:ExprOf<Class<T>>):ExprOf<MapTo<T>> {
		return macro new MapTo(cast $self.components[$type._TYPE_ID]);
	}
}