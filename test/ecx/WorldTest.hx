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
		Assert.notNull(world.engine.entityManager);
		Assert.notNull(world.engine.components);
		Assert.notNull(world.engine.entityManager.updateFlags);
		Assert.notNull(world.engine.entityManager.removeFlags);
		Assert.notNull(world.engine.worlds);
	}
}