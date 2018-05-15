package ecx;

import utest.Assert;
import ecx.systems.MotionSystem;

class FamilyTest extends EcxTest {

	public function new() {
		super();
	}

	public function testCommit() {
		var ms:MotionSystem = world.resolve(MotionSystem);

		Assert.notNull(ms);
		Assert.notNull(ms.entities);
		Assert.notNull(ms.position);
		Assert.notNull(ms.motion);

		var entity = world.create();
		ms.motion.create(entity);
		ms.position.create(entity);
		world.commit(entity);
		world.invalidate();

		Assert.equals(1, ms.entities.length);
		Assert.equals(entity.id, ms.entities.get(0));

		ms.motion.destroy(entity);
		world.commit(entity);
		world.invalidate();
		Assert.equals(0, ms.entities.length);
	}
}
