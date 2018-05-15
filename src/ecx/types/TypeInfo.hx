package ecx.types;

@:final
@:unreflective
class TypeInfo {

    public var path(default, null):String;
    public var basePath(default, null):String;
    public var typeId(default, null):Int;
    public var specId(default, null):Int;

    function new(path:String, basePath:String, typeId:Int, specId:Int) {
        this.path = path;
        this.basePath = basePath;
        this.typeId = typeId;
        this.specId = specId;
    }
}