package ecx;

import ecx.ds.PowerOfTwo;
import utest.Assert;

class PowerOfTwoTest {

	public function new() {}

	public function testCheck() {
		// smoke tests
		Assert.isTrue(PowerOfTwo.check(0x1));
		Assert.isTrue(PowerOfTwo.check(0x1));
		Assert.isTrue(PowerOfTwo.check(0x2));
		Assert.isTrue(PowerOfTwo.check(0x4));
		Assert.isTrue(PowerOfTwo.check(0x8));
		Assert.isTrue(PowerOfTwo.check(0x10));
		Assert.isTrue(PowerOfTwo.check(0x100));

		Assert.isFalse(PowerOfTwo.check(0));
		Assert.isFalse(PowerOfTwo.check(0xFF));
		Assert.isFalse(PowerOfTwo.check(0xF));
		Assert.isFalse(PowerOfTwo.check(0x3));
	}

	public function testRequire() {
		Assert.equals(1, PowerOfTwo.require(0));
		Assert.equals(0x100, PowerOfTwo.require(0xFF));
		Assert.equals(0x100, PowerOfTwo.require(0x100));
	}

	public function testNext() {
		Assert.equals(1, PowerOfTwo.next(0));
		Assert.equals(16, PowerOfTwo.next(10));
		Assert.equals(512, PowerOfTwo.next(256));
		Assert.equals(256, PowerOfTwo.next(255));
	}
}
