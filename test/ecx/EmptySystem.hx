package ecx;

import ecx.components.TestPosition;
import ecx.components.Value;

class EmptySystem extends System {

	var _entities:Family<Value, TestPosition>;

	public function new() {}

	override function update() {
		for(entity in _entities) {
		}
	}
}
