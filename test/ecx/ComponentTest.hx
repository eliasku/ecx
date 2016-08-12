package ecx;

import ecx.components.Value;
import utest.Assert;

class ComponentTest extends EcxTest {

	public function new() {
		super();
	}

	public function setup() {
		world.invalidate();
	}

	public function testComponentCreate() {
		var e = world.edit(world.create());

		var v:Value = e.create(Value);
		Assert.notNull(v);
		Assert.equals(e.id, v.entity.id);
		Assert.equals(world, v.world);

		v.value = 10;
		Assert.equals(10, v.value);

		e.delete();
		world.invalidate();

		Assert.isNull(v.world);
		Assert.isTrue(v.entity.isInvalid);
	}

	public function testComponentDelete() {
		var e = world.edit(world.create());
		var v:Value = e.create(Value);
		Assert.notNull(v);

		e.remove(Value);
		Assert.isFalse(v.entity.isValid);
		Assert.isNull(v.world);

		var noValue = e.get(Value);
		Assert.isNull(noValue);

		e.delete();
	}
}