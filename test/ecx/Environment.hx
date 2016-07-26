package ecx;

class Environment {
	static var _current:Environment;

	public static function get() {
		if(_current == null) {
			_current = new Environment();
		}
		return _current;
	}

	public var world(default, null):World;

	public function new() {
		var config = new WorldConfig();
		config.add(new EmptySystem());
		world = Engine.initialize().createWorld(config);
	}
}