package ecx;

import ecx.Engine;
import ecx.components.TestPosition;
import ecx.components.TestComponent;
import utest.Assert;

@:keep
class TestCase {

	var world:World;

	public function new() {}

	public function setup() {
		var config = new WorldConfig();
		config.add(new EmptySystem());
		world = Engine.create(config);
	}

	public function testAccess() {
		var e = world.create();
		e.create(TestComponent);
		Assert.notNull(e.get(TestComponent));
		Assert.equals(0, e.get(TestComponent).val);
		e.get(TestComponent).val = 1;
		Assert.equals(1, e.get(TestComponent).val);
		//trace("1: " + Database.typeId(TestPosition));
//		trace("2: " + e.database.components[Database.typeId(TestPosition)]);
//		trace("3: " + e.database.components[Database.typeId(TestPosition)].length);
//		trace("TEST POSITION: " + e.id + " - " + e.get(TestPosition));
		Assert.isNull(e.get(TestPosition));
	}

	public function testClone() {
		var e1 = world.create();
		e1.create(TestComponent);
		var e2 = world.create();
		var e3 = world.clone(e1);
		var e4 = world.clone(e2);
		Assert.isTrue(e3.has(TestComponent));
		Assert.isFalse(e4.has(TestComponent));
	}

	public function testComponentsTraversal() {
		var e:Entity = world.create();
		e.create(TestComponent);
		e.create(TestPosition);
		var keys = [];
		var values = [];
		var components = e.database.components;
		for(key in 0...components.length) {
			keys.push(key);
			var value = components[key][e.id];
			values.push(value);
			trace(key + ": " + (value != null));
		}
		Assert.equals(2, keys.length);
		Assert.equals(2, values.length);
	}

	public function testGetMacro() {
		var expectedEntitiesCount:Int = world.entitiesTotal;

		// entity need to be created once!
		Assert.isNull(world.create().get(TestPosition));
		expectedEntitiesCount++;

		// entity need to be created once!
		var e:Entity = null;
		Assert.isNull((e != world.create() ? e : e).tryGet(TestPosition));
		expectedEntitiesCount++;

		Assert.equals(expectedEntitiesCount, world.entitiesTotal);
	}


	public function teardown() {
		world = null;
	}
}