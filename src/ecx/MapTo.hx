package ecx;

import ecx.ds.CArray;

// TODO: cs & java arrays covariance
#if (flash||cs||java)
private typedef MTD<T> = CArray<Component>;
#else
private typedef MTD<T> = CArray<T>;
#end

@:generic
@:final
@:unreflective
@:dce
abstract MapTo<T>(MTD<T>) {

	@:generic inline public function new<T>(arr:MTD<T>) {
		this = arr;
	}

	inline public function get(entity:Entity):T {
		#if (flash||cs||java)
		return cast this[entity.id];
		#else
		return this[entity.id];
		#end
	}

	@:arrayAccess
	inline public function getFast(id:Int):T {
		#if (flash||cs||java)
		return cast this[id];
		#else
		return this[id];
		#end
	}
}