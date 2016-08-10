package ecx.types;

@:final
@:unreflective
class TypeInfo {

    public var kind(default, null):TypeKind;
    public var path(default, null):String;
    public var basePath(default, null):String;
    public var typeId(default, null):Int;
    public var specId(default, null):Int;

    function new(kind:TypeKind, path:String, basePath:String, typeId:Int, specId:Int) {
        this.kind = kind;
        this.path = path;
        this.basePath = basePath;
        this.typeId = typeId;
        this.specId = specId;
    }
}