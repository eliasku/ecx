package ecx.types;

/** [INTERNAL] Service's specialization type-identifier **/

@:dce @:final @:unreflective
abstract ServiceSpec(Int) {

	public inline static var INVALID:ServiceSpec = new ServiceSpec(-1);

	public var id(get, never):Int;

	inline public function new(specId:Int) {
		this = specId;
	}

	inline function get_id():Int {
		return this;
	}

	inline public function toString() {
		return 'Spec: #$this';
	}
}
