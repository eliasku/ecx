package ecx.types;

/** [INTERNAL] Service's base type-identifier **/

@:dce @:final @:unreflective
abstract ServiceType(Int) {

	public inline static var INVALID:ServiceType = new ServiceType(-1);

	public var id(get, never):Int;

	inline public function new(typeId:Int) {
		this = typeId;
	}

	inline function get_id():Int {
		return this;
	}

	inline public function toString() {
		return 'SystemType: #$this';
	}
}
