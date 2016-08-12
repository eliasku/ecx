package ecx.macro;

#if macro

import ecx.types.TypeKind;

@:final
class TypeMacroData {

    static var NEXT_TYPE_ID:Array<Int> = [0, 0];
    static var NEXT_SPEC_ID:Array<Int> = [0, 0];

    // Base Family full name (some.foo.Bar)
    public var basePath(default, null):String;

    // Full class path (some.foo.Bar)
    public var path(default, null):String;

    // kind of type (component or system)
    public var kind(default, null):TypeKind;

    // common base type id
    public var typeId(default, null):Int;

    // specific unique type index for implementations
    public var specId(default, null):Int;

    public var isBase(default, null):Bool;

    public function new(kind:TypeKind, basePath:String, path:String, baseTypeId:Int = -1) {
        this.kind = kind;
        this.basePath = basePath;
        this.path = path;
        typeId = baseTypeId >= 0 ? baseTypeId : (NEXT_TYPE_ID[kind]++);
        specId = NEXT_SPEC_ID[kind]++;
        isBase = basePath == path;
    }
}

#end