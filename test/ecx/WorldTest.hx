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
		Assert.notNull(world.entityManager);
		Assert.notNull(world.components);
		Assert.notNull(world.entityManager.changedFlags);
		Assert.notNull(world.entityManager.removedFlags);
		Assert.notNull(world.entityManager.activeFlags);
	}
}