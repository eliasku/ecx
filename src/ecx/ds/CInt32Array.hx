package ecx.ds;

#if js
private typedef CInt32ArrayData = js.html.Int32Array;
#else
private typedef CInt32ArrayData = CArray<Int>;
#end

@:generic
@:final
@:unreflective
@:dce
abstract CInt32Array(CInt32ArrayData) {

	public var length(get, never):Int;

	inline public function new(length:Int) {
		this = new CInt32ArrayData(length);
	}

	inline function get_length() {
		return this.length;
	}

	@:arrayAccess
	inline public function get(index:Int):Int {
		return this[index];
	}

	@:arrayAccess
	inline public function set(index:Int, element:Int):Void {
		this[index] = element;
	}
}