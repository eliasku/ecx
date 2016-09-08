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
		var e = world.create();
		var inactiveEntity = world.createPassive();

		Assert.isTrue(e.notNull());
		Assert.isTrue(inactiveEntity.notNull());

		Assert.isTrue(world.checkAlive(e));
		Assert.isTrue(world.checkAlive(inactiveEntity));

		Assert.isTrue(world.isActive(e));
		Assert.isFalse(world.isActive(inactiveEntity));

		world.destroy(e);
		world.destroy(inactiveEntity);

		world.invalidate();

		Assert.isFalse(world.checkAlive(e));
		Assert.isFalse(world.checkAlive(inactiveEntity));

		Assert.isFalse(world.isActive(e));
		Assert.isFalse(world.isActive(inactiveEntity));

//		Assert.equals(world, e.world);
//		Assert.equals(world, inactiveEntity.world);

//		Assert.isTrue(e.alive);
//		Assert.isTrue(inactiveEntity.alive);

//		Assert.isTrue(e.active);
//		Assert.isFalse(inactiveEntity.active);

//		e.delete();
//		inactiveEntity.delete();

//		world.invalidate();
//
//		Assert.isFalse(e.active);
//		Assert.isFalse(e.alive);
//
//		Assert.isFalse(inactiveEntity.active);
//		Assert.isFalse(inactiveEntity.alive);
	}
}