package ecx;

import ecx.ds.CArray;

@:generic
abstract MapTo<T>(CArray<T>) {

	@:generic inline public function new<T>(arr:CArray<Component>) {
		this = cast arr;
	}

	inline public function get(entity:Entity):T {
		return this[entity.id];
	}

	@:arrayAccess
	inline public function getFast(id:Int):T {
		return this[id];
	}
}