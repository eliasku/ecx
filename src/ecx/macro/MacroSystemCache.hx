package ecx.macro;

#if macro

@:final
class MacroSystemCache {

    public static var cache(default, null):Map<String, MacroSystemData> = new Map();

    public static function get(path:String):Null<MacroSystemData> {
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

    public static function set(data:MacroSystemData) {
        cache.set(data.path, data);
    }
}

#end