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
		Assert.notNull(world.database.edb);
		Assert.notNull(world.database.components);
		Assert.notNull(world.database.flags);
		Assert.notNull(world.database.worlds);
	}
}