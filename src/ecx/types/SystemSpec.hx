package ecx.types;

/** [INTERNAL] Component Specific Type identifier**/
@:dce @:final @:unreflective
abstract SystemSpec(Int) to Int {

    public inline static var INVALID:SystemSpec = new SystemSpec(-1);

    public var id(get, never):Int;
    inline function get_id():Int {
        return this;
    }

    inline public function new(specId:Int) {
        this = specId;
    }

    inline public function toString() {
        return 'SystemSpec: #$this';
    }
}
