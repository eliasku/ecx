package ecx;

@:generic
abstract MapTo<T>(Array<T>) {

	@:generic inline public function new<T>(arr:Array<Component>) {
		this = cast arr;
	}

	inline public function get(entity:Entity):T {
		return this[entity.id];
	}

	@:arrayAccess
	inline public function getFast(id:Int):T {
		return this[id];
	}
}