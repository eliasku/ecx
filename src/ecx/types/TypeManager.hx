package ecx.types;

@:final
@:access(ecx.types.TypeInfo)
class TypeManager {

    public var components(default, null):Array<TypeInfo> = [];
    public var systems(default, null):Array<TypeInfo> = [];
    public var lookup(default, null):Map<String, TypeInfo> = new Map();
    public var lastComponentId(default, null):Int;

    public function new() {
        var clist = haxe.rtti.Meta.getType(TypeManager);
        var typesDataMeta:Array<Dynamic> = Reflect.field(clist, "types_data");
        var i = 0;
        var maxCid = 0;
        while(i < typesDataMeta.length) {
            var fullname = typesDataMeta[i];
            var kind = typesDataMeta[i + 1];
            var id = typesDataMeta[i + 2];
            var index = typesDataMeta[i + 3];
            var typeInfo = new TypeInfo(fullname, kind, id, index);
            if(kind == 0) {
                components.push(typeInfo);
                if(kind == 0 && id > maxCid) {
                    maxCid = id;
                }
            }
            else if(kind == 1) {
                systems.push(typeInfo);
            }
            lookup.set(fullname, typeInfo);
            i += 4;
        }
        lastComponentId = maxCid;
    }
}
