package ecx;

import ecx.types.ComponentsArrayData;
import ecx.ds.CArray;

// TODO: compile-time error if not component type or not @:base component type

@:generic
@:final
@:unreflective
@:dce
abstract MapTo<T:Component>(CArray<T>) {

	//TODO: add ':Component' (after IDEA will be fixed)
	@:generic inline public function new<T:Component>(cls:Class<T>, arr:ComponentsArrayData) {
		this = cast arr;
	}

	@:arrayAccess
	inline public function get(entity:Entity):T {
		return this[entity.id];
	}
}