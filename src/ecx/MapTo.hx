package ecx;

import ecx.ds.CArray;

// TODO: cs & java arrays covariance
// TODO: typed component storage

#if (flash||cs||java)
private typedef MapToData<T> = CArray<Component>;
#else
private typedef MapToData<T> = CArray<T>;
#end

@:generic
@:final
@:unreflective
@:dce
abstract MapTo<T:Component>(MapToData<T>) {

	@:generic inline public function new<T:Component>(arr:MapToData<T>) {
		this = arr;
	}

	@:arrayAccess
	inline public function get(entity:Int):T {
		#if (flash||cs||java)
		return cast this[entity];
		#else
		return this[entity];
		#end
	}
}