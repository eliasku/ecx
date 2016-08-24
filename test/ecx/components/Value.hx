package ecx.components;

import ecx.storage.AutoComp;
import ecx.storage.ComponentArray;

class Value extends ComponentArray implements AutoComp<ValueData> {}

class ValueData extends Component {

	var _value:Int = 0;

	public var value(get, set):Int;

	public function new() {}

	function get_value():Int {
		return _value;
	}

	function set_value(value:Int):Int {
		return _value = value;
	}
}

