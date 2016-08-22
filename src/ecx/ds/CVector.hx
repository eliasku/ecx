package ecx.ds;

#if flash
private typedef BufferData<T> = flash.Vector<T>;
#else
private typedef BufferData<T> = Array<T>;
#end

// TODO: @:generic only for `cpp` target?

@:generic @:dce @:unreflective @:final
class CVector<T> {

	public var length(default, null):Int = 0;
	public var buffer(default, null):BufferData<T>;

	inline public function new() {
		buffer = new BufferData();
	}

	inline public function get(index:Int):T {
		return buffer[index];
	}

	inline public function set(index:Int, element:T) {
		buffer[index] = element;
	}

	inline public function has(element:T):Bool {
		return buffer.lastIndexOf(element, length - 1) >= 0;
	}

	inline public function remove(element:T) {
		buffer.splice(buffer.lastIndexOf(element, --length), 1);
	}

	inline public function push(element:T) {
		buffer[length++] = element;
	}

	inline public function pop():T {
		return buffer[length--];
	}

	inline public function reset() {
		length = 0;
	}

	inline public function iterator():CVectorIterator<T> {
		return new CVectorIterator(this);
	}
}

@:final @:unreflective @:dce @:generic
class CVectorIterator<T> {

	public var index:Int;
	public var end:Int;
	public var buffer:BufferData<T>;

	inline public function new(v:CVector<T>) {
		index = 0;
		end = v.length;
		buffer = v.buffer;
	}

	inline public function hasNext():Bool {
		return index != end;
	}

	inline public function next():T {
		return buffer[index++];
	}
}