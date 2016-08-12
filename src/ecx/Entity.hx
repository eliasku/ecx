package ecx;

@:dce @:final @:unreflective
abstract Entity(Int) {

    public static inline var INVALID:Entity = new Entity(-1);

    inline function new(id:Int) {
        this = id;
    }

    public var isValid(get, never):Bool;
    inline function get_isValid():Bool {
        return this >= 0;
    }

    public var isInvalid(get, never):Bool;
    inline function get_isInvalid():Bool {
        return this < 0;
    }

    public var id(get, never):Int;
    inline function get_id():Int {
        return this;
    }
}
