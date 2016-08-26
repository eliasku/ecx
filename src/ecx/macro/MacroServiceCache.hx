package ecx.macro;

#if macro

@:final
class MacroServiceCache {

    public static var cache(default, null):Map<String, MacroServiceData> = new Map();

    public static function get(path:String):Null<MacroServiceData> {
        return cache.get(path);
    }

    public static function getBaseTypeId(path:String, basePath:String):Int {
        if(path == basePath) {
            return -1;
        }
        var baseTypeData = get(basePath);
        if(baseTypeData == null) {
            return -1;
        }
        return baseTypeData.typeId;
    }

    public static function set(data:MacroServiceData) {
        cache.set(data.path, data);
    }
}

#end