package ecx;

import ecx.systems.DerivedTwoSystem;
import ecx.systems.BaseSystem;
import utest.Assert;

class ServiceHierarchyTest extends EcxTest {

	public function new() {
		super();
	}

	public function setup() {
		world.invalidate();
	}

	public function testResolve() {
		var base:BaseSystem = world.resolve(BaseSystem);
		var derivedTwo:DerivedTwoSystem = world.resolve(DerivedTwoSystem);
		Assert.notNull(base);
		Assert.notNull(derivedTwo);
		Assert.isTrue(base == derivedTwo);
		Assert.equals(base.ok, "OK_2");

		// TODO:
//		var derivedOne = world.resolve(DerivedOneSystem);
//		Assert.isNull(derivedOne);
	}
}