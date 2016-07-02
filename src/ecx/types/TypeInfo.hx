package ecx.types;

@:final
@:unreflective
class TypeInfo {
    public var path(default, null):String;
    public var id(default, null):Int;
    public var index(default, null):Int;
    public var kind(default, null):TypeKind;

    public function new(path:String, kind:TypeKind, id:Int, index:Int) {
        this.path = path;
        this.id = id;
        this.index = index;
        this.kind = kind;
    }
}
