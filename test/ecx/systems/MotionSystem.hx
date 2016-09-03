package ecx.systems;

import ecx.components.Position;
import ecx.components.Motion;

class MotionSystem extends System {

	public var entities(default, null):Family<Motion, Position>;

	public var motion(default, null):Wire<Motion>;
	public var position(default, null):Wire<Position>;

	public function new() {}
}
