package ecx.macro;
#if macro

@:final
class MacroComponentCache {

	public static var cache(default, null):Map<String, MacroComponentData> = new Map();

	public static function get(path:String):Null<MacroComponentData> {
		return cache.get(path);
	}

	public static function set(data:MacroComponentData) {
		cache.set(data.path, data);
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
}

#end