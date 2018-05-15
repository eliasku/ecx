package ecx.ds;

@:final @:unreflective @:dce @:generic
class CArrayIterator<T> {

	public var index:Int;
	public var end:Int;
	public var array:CArray<T>;

	inline public function new(array:CArray<T>) {
		index = 0;
		end = array.length;
		this.array = array;
	}

	inline public function hasNext():Bool {
		return index != end;
	}

	inline public function next():T {
		return array[index++];
	}
}
