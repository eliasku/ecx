package ecx.macro;

#if macro

@:final
class MacroServiceData {

    static var NEXT_TYPE_ID:Int = 0;
    static var NEXT_SPEC_ID:Int = 0;

    // Base Family full name (some.foo.Bar)
    public var basePath(default, null):String;

    // Full class path (some.foo.Bar)
    public var path(default, null):String;

    // common base type id
    public var typeId(default, null):Int;

    // specific unique type index for implementations
    public var specId(default, null):Int;

    public var isBase(default, null):Bool;

    public function new(basePath:String, path:String, baseTypeId:Int = -1) {
        this.basePath = basePath;
        this.path = path;
        typeId = baseTypeId >= 0 ? baseTypeId : (NEXT_TYPE_ID++);
        specId = NEXT_SPEC_ID++;
        isBase = basePath == path;
    }
}

#end