package ecx;

import ecx.components.Position;
import ecx.components.Value;
import utest.Assert;

@:keep
class IssuesTest extends EcxTest {

	public function new() {
		super();
	}

	public function testAccess() {
		var value:Value = world.resolve(Value);
		var entity = world.create();
		value.create(entity);
		Assert.notNull(value.get(entity));
		Assert.equals(0, value.get(entity).value);
		value.get(entity).value = 1;
		Assert.equals(1, value.get(entity).value);

		var testPosition:Position = world.resolve(Position);
		Assert.isNull(testPosition.get(entity));
	}

	public function testClone() {
		var value:Value = world.resolve(Value);
		var e1 = world.create();
		var e2 = world.create();
		value.create(e1);

		var e3 = world.clone(e1);
		var e4 = world.clone(e2);

		Assert.isTrue(value.has(e3));
		Assert.isFalse(value.has(e4));
	}

	public function testComponentsTraversal() {
		var e = world.create();
		var value:Value = world.resolve(Value);
		var position:Position = world.resolve(Position);

		value.create(e);
		position.create(e);

		var values = [];
		for(component in world.components()) {
			var value = component.has(e);
			if(value) {
				values.push(value);
			}
		}
		Assert.equals(2, values.length);
	}

	public function testGetMacro() {
		var value:Value = world.resolve(Value);
		var testPosition:Position = world.resolve(Position);
		var expectedEntitiesCount:Int = world.used;

		// entity need to be created once!
		Assert.isNull(testPosition.get(world.create()));
		expectedEntitiesCount++;

		// entity need to be created once!
//		Assert.isNull((e != world.edit(world.create()) ? e : null).tryGet(TestPosition));
//		expectedEntitiesCount++;

		Assert.equals(expectedEntitiesCount, world.used);
	}
}