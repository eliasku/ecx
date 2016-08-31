package ecx;

import ecx.components.Value;
import ecx.components.TestPosition;

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

		config.add(new Value());
		config.add(new TestPosition());
		world = Engine.createWorld(config, 1000);
	}
}