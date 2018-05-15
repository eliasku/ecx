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

	inline public function notNull():Bool {
		return id != 0;
	}

	inline public function isNull():Bool {
		return id == 0;
	}

	inline function get_id():Int {
		#if js
		return this | 0;
		#else
		return this;
		#end
	}
}
