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
		var e:Entity = world.create();

		var v:Value = e.create(Value);
		Assert.notNull(v);
		Assert.equals(e, v.entity);
		Assert.equals(world, v.world);

		v.value = 10;
		Assert.equals(10, v.value);

		world.delete(e);
	}

	public function testComponentDelete() {
		var e:Entity = world.create();
		var v:Value = e.create(Value);
		Assert.notNull(v);

		e.remove(Value);
		Assert.isNull(v.entity);
		Assert.isNull(v.world);

		var noValue = e.get(Value);
		Assert.isNull(noValue);

		world.delete(e);
	}
}