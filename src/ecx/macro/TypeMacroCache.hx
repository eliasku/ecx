package ecx.macro;

#if macro

import ecx.types.TypeKind;

@:final
class TypeMacroCache {

    static var _cache:Map<TypeKind, Map<String, TypeMacroData>> = new Map();

    public static function getTypeMap(kind:TypeKind):Map<String, TypeMacroData> {
        var map = _cache.get(kind);
        if(map == null) {
            map = new Map();
            _cache.set(kind, map);
        }
        return map;
    }

    public static function getType(kind:TypeKind, path:String):Null<TypeMacroData> {
        return getTypeMap(kind).get(path);
    }

    public static function getBaseTypeId(kind:TypeKind, path:String, basePath:String):Int {
        if(path == basePath) {
            return -1;
        }
        var baseTypeData = getType(kind, basePath);
        if(baseTypeData == null) {
            return -1;
        }
        return baseTypeData.typeId;
    }


    public static function set(data:TypeMacroData) {
        getTypeMap(data.kind).set(data.path, data);
    }

// TODO: final
}

#end