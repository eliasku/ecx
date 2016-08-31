package ecx.storage;

import ecx.types.ComponentType;

#if !macro
@:autoBuild(ecx.storage.AutoCompBuilder.build())
#end
@:base
class AutoComp<T> extends Service implements Component<T> {

	public function get(entity:Entity):T {
		return null;
	}

	public function set(entity:Entity, component:T) {}
	public function has(entity:Entity):Bool {
		return false;
	}

	public function create(entity:Entity):T {
		return null;
	}

	public function remove(entity:Entity) {}
	public function copy(source:Entity, destination:Entity) {}

	public function __componentType() {
		return ComponentType.INVALID;
	}
}
