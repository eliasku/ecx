package ecx.types;

@:final
@:unreflective
@:access(ecx.types.TypeInfo)
class TypeManager {

    public var components(default, null):Array<TypeInfo> = [];
    public var componentsTotal(default, null):Int;
//    public var systems(default, null):Array<TypeInfo> = [];
//    public var lookup(default, null):Map<String, TypeInfo> = new Map();

    public function new() {
        var meta = haxe.rtti.Meta.getType(TypeManager);
        var systemsData:Array<Dynamic> = Reflect.field(meta, "systems");
        var componentsData:Array<Dynamic> = Reflect.field(meta, "components");
        if(systemsData == null) {
            systemsData = [];
        }
        if(componentsData == null) {
            componentsData = [];
        }

        var i = 0;
        var maxComponentTypeId = -1;
        while(i < componentsData.length) {
            var path = componentsData[i];
            var basePath = componentsData[i + 1];
            var typeId = componentsData[i + 2];
            var specId = componentsData[i + 3];

            if(typeId > maxComponentTypeId) {
                maxComponentTypeId = typeId;
            }

            i += 4;
        }

        componentsTotal = maxComponentTypeId + 1;
    }

//    public function getTypeInfoByComponentType(componentType:ComponentType):TypeInfo {
//        for(typeInfo in components) {
//            if(typeInfo.typeId == componentType.id) {
//                return typeInfo;
//            }
//        }
//        throw 'Component type-info with type: ${componentType.id} not found';
//    }
}
