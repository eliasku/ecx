package ecx.components;

class Motion extends AutoComp<MotionData> {}

class MotionData {

	public var vx:Float = 0;
	public var vy:Float = 0;

	public function new() {}

	public function copyFrom(data:MotionData) {
		vx = data.vx;
		vy = data.vy;
	}
}
