package ecx;

#if flash
private typedef FastArrayData<T> = flash.Vector<T>;
#else
private typedef FastArrayData<T> = Array<T>;
#end

abstract FastArray<T>(FastArrayData<T>) {

	public var length(get, never):Int;

	public inline function new(initialLength:Int) {
		#if flash
		this = new flash.Vector<T>(initialLength, false);
		#elseif js
		this = untyped __new__(Array, initialLength);
		#elseif cpp
		this = new Array<T>();
		untyped this.__SetSize(initialLength);
		#elseif (macro||neko)
		this = [];
		for(i in 0...initialLength) {
			this.push(null);
		}
		#else
		this = [];
		untyped this.length = initialLength;
		#end
	}

	@:op([])
	public inline function get(index:Int):Null<T> {
//#if cpp
//		return cpp.NativeArray.unsafeGet(this, index);
//#else
		return this[index];
//#end
	}

	@:op([])
	public inline function set(index:Int, val:T):T {
//#if cpp
//		return cpp.NativeArray.unsafeSet(this, index, val);
//#else
		return this[index] = val;
//#end
	}

	inline function get_length():Int {
		return this.length;
	}

	public inline function push(element:T):Void {
		this.push(element);
	}

	public inline function insert(element:T, at:Int):Void {
		#if flash
		throw "not implemented";
		#else
		this.insert(at, element);
		#end
	}

	public inline function removeAt(index:Int):Void {
		this.splice(index, 1);
	}

	public inline function clear():Void {
		this.splice(0, length);
	}

	public inline function toData():FastArrayData<T> {
		return cast this;
	}

	static public inline function fromData<T>(data:FastArrayData<T>):FastArrayData<T> {
		return cast data;
	}
}
