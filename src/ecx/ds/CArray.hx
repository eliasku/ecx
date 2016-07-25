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
	Dense Fixed-size array (CArray is const-size-array)
**/
abstract CArray<T>(CArrayData<T>) {

	public var length(get, never):Int;

	inline public function new(length:Int) {
		#if flash
		this = new flash.Vector<T>(length, true);
		#elseif js
		this = untyped __new__(Array, length);
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
	inline function get(index:Int):T {
		return this[index];
	}

	@:arrayAccess
	inline function set(index:Int, element:T):Void {
		this[index] = element;
	}
}
