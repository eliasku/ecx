package ecx;

class EcxTest {

	public var env(default, null):Environment;
	public var world(default, null):World;

	public function new() {
		env = Environment.get();
		world = env.world;
	}
}