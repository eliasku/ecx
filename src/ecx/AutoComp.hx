package ecx;

import ecx.types.ComponentType;

#if !macro
@:autoBuild(ecx.macro.AutoCompBuilder.build())
#end
@:core
class AutoComp<T> extends Service implements IComponent {

	#if idea
	public function get(entity:Entity):T return null;
	public function set(entity:Entity, component:T) {}
	public function create(entity:Entity):T return null;
	#end

	public function has(entity:Entity):Bool {
		return false;
	}

	public function remove(entity:Entity) {}
	public function copy(source:Entity, destination:Entity) {}

	public function __componentType() {
		return ComponentType.INVALID;
	}
}
