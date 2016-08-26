package ecx.types;

@:dce @:final @:unreflective
@:enum abstract SystemFlags(Int) {

    // system is not a part of game loop, update method is not called every frame
    var IDLE = 2;

    // system only initialize something, so it will be removed after initialization
    var CONFIG = 4;

    inline public function new(bits:Int = 0) {
        this = bits;
    }

    inline public function has(flags:SystemFlags):Bool {
        return (this & flags.value) != 0;
    }

    inline public function add(flags:SystemFlags):SystemFlags {
        return new SystemFlags(this | flags.value);
    }

    public var value(get, never):Int;
    inline function get_value():Int {
        return this;
    }
}