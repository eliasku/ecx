package ecx;

import ecx.ds.CArray;

// TODO: compile-time error if not component type or not @:base component type

@:generic
@:final
@:unreflective
@:dce
abstract MapTo<T:Component>(CArray<T>) {

	@:generic inline public function new<T:Component>(componentClass:Class<T>, componentsArray:CArray<T>) {
		this = componentsArray;
	}

	@:arrayAccess
	inline public function get(entity:Entity):T {
		return this[entity.id];
	}
}