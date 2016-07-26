package ecx;

import ecx.components.TestPosition;
import ecx.components.Value;
import utest.Assert;

@:keep
class IssuesTest extends EcxTest {

	public function new() {
		super();
	}

	public function testAccess() {
		var e = world.create();
		e.create(Value);
		Assert.notNull(e.get(Value));
		Assert.equals(0, e.get(Value).value);
		e.get(Value).value = 1;
		Assert.equals(1, e.get(Value).value);
		//trace("1: " + Database.typeId(TestPosition));
//		trace("2: " + e.database.components[Database.typeId(TestPosition)]);
//		trace("3: " + e.database.components[Database.typeId(TestPosition)].length);
//		trace("TEST POSITION: " + e.id + " - " + e.get(TestPosition));
		Assert.isNull(e.get(TestPosition));
	}

	public function testClone() {
		var e1 = world.create();
		e1.create(Value);
		var e2 = world.create();
		var e3 = world.clone(e1);
		var e4 = world.clone(e2);
		Assert.isTrue(e3.has(Value));
		Assert.isFalse(e4.has(Value));
	}

	public function testComponentsTraversal() {
		var e:Entity = world.create();
		e.create(Value);
		e.create(TestPosition);
		var keys = [];
		var values = [];
		var components = e.engine.components;
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
}