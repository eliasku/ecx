package ecx.types;

@:final
@:unreflective
@:access(ecx.types.TypeInfo)
class TypeManager {

    static inline var META_FIELDS_PER_INFO:Int = 5;

    // TODO: typed component storage
//    public var compalcl(default, null):Array<Dynamic> = [];
//    public var compal(default, null):Array<Dynamic> = [];

    public var components(default, null):Array<TypeInfo> = [];
    public var componentsNextTypeId(default, null):Int;
    public var systems(default, null):Array<TypeInfo> = [];
    public var lookup(default, null):Map<String, TypeInfo> = new Map();

    public function new() {
        var typesMeta = haxe.rtti.Meta.getType(TypeManager);
        var typesData:Array<Dynamic> = Reflect.field(typesMeta, "types_data");
        var i = 0;
        var maxComponentTypeId = 0;
        while(i < typesData.length) {
            var kind = typesData[i];
            var path = typesData[i + 1];
            var basePath = typesData[i + 2];
            var typeId = typesData[i + 3];
            var specId = typesData[i + 4];
            var info = new TypeInfo(kind, path, basePath, typeId, specId);

            switch(kind) {
                case TypeKind.COMPONENT:
                    // TODO: typed component storage
//                compalcl[id] = Type.resolveClass(fullname);
//                compal[id] = Reflect.field(compalcl[id], "_allocTypedArray");
                    components.push(info);
                    if(typeId > maxComponentTypeId) {
                        maxComponentTypeId = typeId;
                    }
                case TypeKind.SYSTEM:
                    systems.push(info);
            }
            lookup.set(path, info);
            i += META_FIELDS_PER_INFO;
        }
        componentsNextTypeId = maxComponentTypeId + 1;
    }
}
