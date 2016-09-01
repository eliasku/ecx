package ecx.components;

class Value extends AutoComp<ValueData> {}

class ValueData {

	var _value:Int = 0;

	public var value(get, set):Int;

	public function new() {}

	function get_value():Int {
		return _value;
	}

	function set_value(value:Int):Int {
		return _value = value;
	}

	public function copyFrom(data:ValueData) {
		_value = data._value;
	}
}

