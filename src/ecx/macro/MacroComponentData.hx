package ecx.macro;

#if macro

@:final
class MacroComponentData {

	static var NEXT_TYPE_ID:Int = 0;

	// Full class path (some.foo.Bar)
	public var path(default, null):String;

	// common base type id
	public var typeId(default, null):Int;

	public function new(path:String) {
		this.path = path;
		typeId = NEXT_TYPE_ID++;
	}
}

#end