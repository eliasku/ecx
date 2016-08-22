package ecx;

import ecx.ds.CArray;

// TODO: compile-time error if not component type or not @:base component type

private typedef MapToData<T> = CArray<T>;

@:generic
@:final
@:unreflective
@:dce
abstract MapTo<T>(MapToData<T>) {

	//TODO: add ':Component' (after IDEA will be fixed)
	@:generic inline public function new<T:Component>(arr:MapToData<T>) {
		this = cast arr;
	}

	@:arrayAccess
	inline public function get(entity:Entity):T {
		return this[entity.id];
	}
}