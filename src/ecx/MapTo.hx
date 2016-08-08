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

	@:arrayAccess
	inline public function get(id:Int):T {
		#if (flash||cs||java)
		return cast this[id];
		#else
		return this[id];
		#end
	}
}