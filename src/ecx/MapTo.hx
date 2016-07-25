package ecx;

import ecx.ds.CArray;

#if flash
private typedef MTD<T> = CArray<Component>;
#else
private typedef MTD<T> = CArray<T>;
#end

@:generic
abstract MapTo<T>(MTD<T>) {

	@:generic inline public function new<T>(arr:MTD<T>) {
		this = arr;
	}

	inline public function get(entity:Entity):T {
		#if flash
		return cast this[entity.id];
		#else
		return this[entity.id];
		#end
	}

	@:arrayAccess
	inline public function getFast(id:Int):T {
		#if flash
		return cast this[id];
		#else
		return this[id];
		#end
	}
}