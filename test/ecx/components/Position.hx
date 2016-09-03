package ecx.components;

class Position extends AutoComp<PositionData> {}

class PositionData {

	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function copyFrom(data:PositionData) {
		x = data.x;
		y = data.y;
	}
}