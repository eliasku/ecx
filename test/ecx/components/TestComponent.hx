package ecx.components;

class TestComponent extends Component {

	var _value:Int = 0;

	public var val(get, set):Int;

	public function new() {}


	function get_val():Int {
		return _value;
	}

	function set_val(value:Int):Int {
		return _value = value;
	}

}