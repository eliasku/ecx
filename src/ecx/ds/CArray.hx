package ecx.ds;

#if (neko||macro)
private typedef CArrayData<T> = neko.NativeArray<T>;
#elseif flash
private typedef CArrayData<T> = flash.Vector<T>;
#elseif java
private typedef CArrayData<T> = java.NativeArray<T>;
#elseif js
private typedef CArrayData<T> = Array<T>;
#elseif cs
private typedef CArrayData<T> = cs.NativeArray<T>;
#else
private typedef CArrayData<T> = Array<T>;
#end

/***
	Dense Fixed-size array (CArray is const-size array)
**/
@:generic
@:final
@:unreflective
@:dce
abstract CArray<T>(CArrayData<T>) from CArrayData<T> {

	public var length(get, never):Int;

	inline public function new(length:Int) {
		#if flash
		this = new flash.Vector<T>(length, true);
		#elseif js
		this = untyped __new__(Array, length);
		for(i in 0...length) this[i] = null;
//		this = untyped Array.apply(null, __new__(Array, length));
//		this = untyped __js__("Array.apply(null, new Array({0}))", length);
		#elseif cpp
		this = new Array<T>();
		cpp.NativeArray.setSize(this, length);
		#elseif java
		this = new java.NativeArray<T>(length);
		#elseif cs
		this = new cs.NativeArray<T>(length);
		#elseif (macro||neko)
		this = neko.NativeArray.alloc(length);
		#else
		this = [for (i in 0...length) null];
		#end
	}

	inline function get_length() {
		#if (macro||neko)
		return neko.NativeArray.length(this);
		#else
		return this.length;
		#end
	}

	@:arrayAccess
	inline public function get(index:Int):T {
		return this[index];
	}

	@:arrayAccess
	inline public function set(index:Int, element:T):Void {
		this[index] = element;
	}

	inline public function iterator():CArrayIterator<T> {
		return new CArrayIterator<T>(this);
	}

	/**
		Theoretic memory size consumed by array, references are not included
	**/
	inline public function getObjectSize():Int {
		return length << 2;
	}

	inline public static function fromArray<T>(array:Array<T>):CArray<T> {
		#if (cpp||python)
		return array.copy();
		#elseif flash
		return flash.Vector.ofArray(array);
		#elseif java
		return java.Lib.nativeArray(array, false);
		#elseif cs
		return cs.Lib.nativeArray(array, false);
		#elseif (neko||macro)
		return neko.NativeArray.ofArrayCopy(array);
		#else
		var result = new CArray<T>(array.length);
		for(i in 0...array.length) {
			result[i] = array[i];
		}
		return result;
		#end
	}
}
