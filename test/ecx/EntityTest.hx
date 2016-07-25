package ecx;

import utest.Assert;

class EntityTest extends EcxTest {

	public function new() {
		super();
	}

	public function setup() {
		world.invalidate();
	}

	public function testInitialize() {
		Assert.notNull(world);
	}

	public function testEntityCreateDelete() {
		var e:Entity = world.create();
		Assert.notNull(e);
		Assert.equals(world, e.world);

		world.delete(e);
		world.invalidate();

		Assert.isNull(e.world);
	}
}