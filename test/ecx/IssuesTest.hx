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
		var entity = world.create();
		var data = world.edit(entity);
		data.create(Value);
		Assert.notNull(data.get(Value));
		Assert.equals(0, data.get(Value).value);
		data.get(Value).value = 1;
		Assert.equals(1, data.get(Value).value);
		//trace("1: " + Database.typeId(TestPosition));
//		trace("2: " + e.database.components[Database.typeId(TestPosition)]);
//		trace("3: " + e.database.components[Database.typeId(TestPosition)].length);
//		trace("TEST POSITION: " + e.id + " - " + e.get(TestPosition));
		Assert.isNull(data.get(TestPosition));
	}

	public function testClone() {
		var e1 = world.edit(world.create());
		e1.create(Value);
		var e2 = world.edit(world.create());
		var e3 = world.edit(world.clone(e1.entity));
		var e4 = world.edit(world.clone(e2.entity));
		Assert.isTrue(e3.has(Value));
		Assert.isFalse(e4.has(Value));
	}

	public function testComponentsTraversal() {
		var e = world.edit(world.create());
		e.create(Value);
		e.create(TestPosition);
		var keys = [];
		var values = [];
		var components = world.components;
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
		var expectedEntitiesCount:Int = world.used;

		// entity need to be created once!
		Assert.isNull(world.edit(world.create()).get(TestPosition));
		expectedEntitiesCount++;

		// entity need to be created once!
		var e:EntityView = null;
		Assert.isNull((e != world.edit(world.create()) ? e : null).tryGet(TestPosition));
		expectedEntitiesCount++;

		Assert.equals(expectedEntitiesCount, world.used);
	}
}