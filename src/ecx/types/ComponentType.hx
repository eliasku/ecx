package ecx.types;

/** [INTERNAL] Component Base Type identifier**/

@:dce @:final @:unreflective
abstract ComponentType(Int) {

    public inline static var INVALID:ComponentType = new ComponentType(-1);

    public var id(get, never):Int;
    inline function get_id():Int {
        return this;
    }

    inline public function new(typeId:Int) {
        this = typeId;
    }

    inline public function toString() {
        return 'ComponentType: #$this';
    }
}
