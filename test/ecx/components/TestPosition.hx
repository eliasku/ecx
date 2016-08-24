package ecx.components;

import ecx.storage.ComponentArray;
import ecx.storage.AutoComp;

class TestPosition extends ComponentArray implements AutoComp<TestPositionData> {}

class TestPositionData extends Component {

	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

}