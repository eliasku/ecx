package ecx.ds;

/**
	Power Of Two integers utility
**/
@:final
@:unreflective
@:dce
class PowerOfTwo {

	/** Returns the next power of two. */
	public static function next(x:Int):Int {
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;
		return x + 1;
	}

	/** Checks if value is power of two **/
	public static function check(x:Int):Bool {
		return x != 0 && (x & (x - 1)) == 0;
	}

	/**
		Returns the specified value if the value is already a power of two.
		Returns next power of two else.
	**/
	public static function require(x:Int):Int {
		if (x == 0) {
			return 1;
		}
		--x;
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;
		return x + 1;
	}
}