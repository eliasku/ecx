package ecx;

import utest.Assert;

class WorldTest extends EcxTest {

	public function new() {
		super();
	}

	public function setup() {
		world.invalidate();
	}

	public function testInitialize() {
		Assert.notNull(world);
	}
}