package ecx.types;

/** [INTERNAL] System base type identifier **/

@:dce @:final @:unreflective
abstract SystemType(Int) to Int {

    public inline static var INVALID:SystemType = new SystemType(-1);

    public var id(get, never):Int;
    inline function get_id():Int {
        return this;
    }

    inline public function new(typeId:Int) {
        this = typeId;
    }

    inline public function toString() {
        return 'SystemType: #$this';
    }
}
