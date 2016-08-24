//package ecx.concept;
//
//import ecx.ds.CArray;
//
//@:generic
//@:base
//
//#if !macro
//@:autoBuild(ecx.macro.TypeBuilder.build(1))
//#end
//class GenericComponent<T> extends ComponentArray {
//
//	var _data:CArray<T>;
//
//	inline public function new() {}
//
//	override function allocate() {
//		_data = new CArray<T>(world.capacity);
//	}
//
//	inline public function get(entity:Entity):T {
//		return (_data[entity.id]:T);
//	}
//
//	inline public function set(entity:Entity, value:T) {
//		_data[entity.id] = value;
//		//onAdded(entity.id, component);
//	}
//
//	inline override public function remove(entity:Entity) {
//		//var component:Component = _data[entity.id];
//		//onRemoved(entity, component);
//		_data[entity.id] = null;
//	}
//
//	inline override public function has(entity:Entity):Bool {
//		return _data[entity.id] != null;
//	}
//
//	inline public function map():CArray<T> {
//		return (_data:CArray<T>);
//	}
//}