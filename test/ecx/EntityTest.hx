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
		var e = world.edit(world.create());
		var inactiveEntity = world.edit(world.createPassive());

		Assert.notNull(e);
		Assert.notNull(inactiveEntity);

		Assert.equals(world, e.world);
		Assert.equals(world, inactiveEntity.world);

		Assert.isTrue(e.alive);
		Assert.isTrue(inactiveEntity.alive);

		Assert.isTrue(e.active);
		Assert.isFalse(inactiveEntity.active);

		e.delete();
		inactiveEntity.delete();

		world.invalidate();

		Assert.isFalse(e.active);
		Assert.isFalse(e.alive);

		Assert.isFalse(inactiveEntity.active);
		Assert.isFalse(inactiveEntity.alive);
	}
}