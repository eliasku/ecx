//package ecx.concept;
//
//import haxe.macro.Expr;
//import ecx.macro.MacroUtil;
//import ecx.ds.CArray;
//
//class WorldExt {
//
//	public var world(default, null):World;
//	public var table(default, null):CArray<ComponentArray>;
//
//	public function new(world:World) {
//		this.world = world;
//	}
//
//	public function build(storage:StorageConfig) {
//		table = new CArray(storage.arrays.length);
//		for(i in 0...storage.arrays.length) {
//			table[i] = storage.arrays[i];
//			@:privateAccess table[i].allocate();
//		}
//	}
//
//	public function create():Entity {
//		return world.create();
//	}
//
//	public function delete(entity:Entity) {
//		for(array in table) {
//			array.remove(entity);
//		}
//	}
//
//	public function clone(entity:Entity):Entity {
//		var cloned = world.create();
//		for(array in table) {
//			array.copy(entity, cloned);
//		}
//		return cloned;
//	}
//}
//
//class StorageConfig {
//	public var arrays:Array<ComponentArray> = [];
//	public function new() {}
//	macro public function add<T>(self:Expr, componentClass:ExprOf<Class<T>>) {
//		var tp = MacroUtil.getConstTypePath(componentClass);
//		var id = macro StorageConfig.cid($componentClass);
//		return macro $self.arrays[StorageConfig.cid($componentClass)] = world.resolve($componentClass);
//	}
//
//	macro static public function cid<T:System>(systemClass:ExprOf<Class<T>>):ExprOf<Int> {
//		return macro $systemClass.CID;
//	}
//}