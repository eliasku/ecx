package ecx.storage;

import ecx.types.ComponentType;

@:base
@:components
class ComponentArray extends System {

	function allocate() {

	}

	public function remove(entity:Entity) {

	}

	public function has(entity:Entity):Bool {
		return false;
	}

	public function copy(source:Entity, destination:Entity) {

	}

	function __componentType():ComponentType {
		return ComponentType.INVALID;
	}
}