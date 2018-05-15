package ecx;

import ecx.systems.DerivedTwoSystem;
import ecx.systems.EmptySystem;
import ecx.systems.MotionSystem;
import ecx.components.Motion;
import ecx.components.Value;
import ecx.components.Position;

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
		config.add(new DerivedTwoSystem());
		config.add(new MotionSystem());

		config.add(new Value());
		config.add(new Motion());
		config.add(new Position());

		world = Engine.createWorld(config, 1000);
	}
}