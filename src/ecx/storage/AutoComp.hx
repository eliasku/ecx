package ecx.storage;

import ecx.types.ComponentType;
import ecx.ds.CArray;

#if !macro
@:autoBuild(ecx.storage.AutoCompBuilder.build())
#end
@:base
class AutoComp<T> extends Service implements Component {


//	var data(default, null):CArray<T>;
//
//	public function get(entity:Entity):T {
//		return data[entity.id];
//	}

//	function set(entity:Entity, component:T):Void {}
//	@:extern function create(entity:Entity):T;
	public function remove(entity:Entity) {}
	public function copy(source:Entity, destination:Entity) {}

	public function has(entity:Entity):Bool {
		return false;
	}

	public function __componentType() {
		return ComponentType.INVALID;
	}
}
