package ecx;

/**
    Entity handle (just integer id)
    - `0` entity id is reserved as INVALID
    - Components slot `0` could be used for storing internal information
**/
@:dce @:final @:unreflective
abstract Entity(Int) {

	/**
		Constant for invalid handle value
	**/
	public static inline var INVALID:Entity = new Entity(0);

	public var id(get, never):Int;
	public var isValid(get, never):Bool;
	public var isInvalid(get, never):Bool;

	inline function new(id:Int) {
		this = id;
	}

	inline function get_isValid():Bool {
		return this > 0;
	}

	inline function get_isInvalid():Bool {
		return this <= 0;
	}

	inline function get_id():Int {
		return this;
	}
}
