package ecx.components;

class TestPosition extends AutoComp<TestPositionData> {}

class TestPositionData {

	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function copyFrom(data:TestPositionData) {
		x = data.x;
		y = data.y;
	}
}