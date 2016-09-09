package ecx;

/**
    Entity handle (just integer id)
    - `0` entity id is reserved as INVALID
    - Components slot `0` could be used for storing internal information
**/
@:dce @:final @:unreflective
abstract Entity(Int) {

	/** Index reserved for null-entity **/
	public static inline var ID_NULL:Int = 0;

	/** Null-entity constant **/
	public static inline var NULL:Entity = new Entity(ID_NULL);

	/** Entity handle ID **/
	public var id(get, never):Int;

	inline function new(id:Int) {
		this = id;
	}

	inline function get_id():Int {
		return this;
	}

	inline public function notNull():Bool {
		#if js
		return (this | 0) != 0;
		#else
		return this != 0;
		#end
	}

	inline public function isNull():Bool {
		#if js
		return (this | 0) == 0;
		#else
		return this == 0;
		#end
	}

	// COMPAT

	/** DEPRECATED! Use `NULL` instead **/
	@:deprecated("Use NULL instead")
	inline public static var INVALID:Entity = new Entity(ID_NULL);

	/** DEPRECATED! Use `notNull()` instead **/
	@:deprecated("Use notNull() instead")
	public var isValid(get, never):Bool;

	/** DEPRECATED! Use `isNull()` instead **/
	@:deprecated("Use isNull() instead")
	public var isInvalid(get, never):Bool;

	inline function get_isValid():Bool {
		return notNull();
	}

	inline function get_isInvalid():Bool {
		return isNull();
	}
}
