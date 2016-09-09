package ecx;

import utest.Assert;
import ecx.types.EntityVector;

class EntityVectorTest {

	public function new() {}

	public function testEnsure() {
		var vec = new EntityVector(2);
		vec.ensure(2);
		Assert.isTrue(vec.buffer.length > 2);
	}

	@:access(ecx.Entity)
	public function testPush() {
		var vec = new EntityVector(2);
		vec.push(new Entity(0));
		vec.push(new Entity(1));
		vec.push(new Entity(2));
		vec.push(new Entity(3));

		Assert.equals(4, vec.length);
		Assert.equals(3, vec.get(3).id);
	}

	@:access(ecx.Entity)
	public function testReset() {
		var vec = new EntityVector(2);
		vec.push(new Entity(0));
		vec.push(new Entity(1));
		vec.push(new Entity(2));
		vec.push(new Entity(3));

		Assert.equals(4, vec.length);
		vec.reset();
		Assert.equals(0, vec.length);
	}

	@:access(ecx.Entity)
	public function testIterator() {
		var vec = new EntityVector(100);
		var elements = [];
		vec.push(new Entity(0));
		vec.push(new Entity(1));
		vec.push(new Entity(2));
		vec.push(new Entity(3));

		var str = "";
		for(el in vec) {
			str += el.id + ",";
		}

		Assert.equals("0,1,2,3,", str);
	}
}
