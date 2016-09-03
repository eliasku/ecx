package ecx.types;

import ecx.ds.CBitArray;
import ecx.ds.CInt32Array;

@:final @:unreflective @:dce
class EntityVector {

	public var length(default, null):Int = 0;
	public var buffer(default, null):CInt32Array;

	inline public function new(initialCapacity:Int = 16) {
		buffer = new CInt32Array(initialCapacity);
	}

	inline public function ensure(maxLength:Int) {
		if (maxLength >= buffer.length) {
			grow(maxLength);
		}
	}

	inline public function push(entity:Entity) {
		ensure(length);
		place(entity);
	}

	inline public function place(entity:Entity) {
		buffer[length] = entity.id;
		++length;
	}

	@:access(ecx.Entity)
	inline public function get(index:Int):Entity {
		return new Entity(buffer[index]);
	}

	public function restoreOrder(mask:CBitArray, startIndex:Int = 0, endIndex:Int = 0) {
		var array:CInt32Array = cast mask;
		var begin = Std.int(startIndex / CBitArray.BITS_PER_ELEMENT);
		var end = endIndex == 0 ? array.length : Math.ceil(endIndex / CBitArray.BITS_PER_ELEMENT);
		var at = 0;
		for(i in begin...end) {
			var value = array[i];
			if(value != 0) {
				var index = i << CBitArray.BIT_SHIFT;
				for(j in 0...CBitArray.BITS_PER_ELEMENT) {
					if((value & (1 << j)) != 0) {
						buffer[at] = index + j;
						++at;
					}
				}
			}
		}
		length = at;
	}

	inline public function reset() {
		length = 0;
	}

	inline public function iterator():EntityMultiSetIterator {
		return new EntityMultiSetIterator(this);
	}

	function grow(newLength:Int) {
		var data = buffer;
		// TODO: new size with current length (increase steps)
		var newSize = Std.int(newLength * 1.5 + 1.0);
		buffer = new CInt32Array(newSize);
		for (i in 0...length) {
			buffer[i] = data[i];
		}
	}

#if ecx_debug
	public function __debugHas(entity:Entity):Bool {
		// TODO: mod bin search
		for(i in 0...length) {
			if(buffer[i] == entity.id) {
				return true;
			}
		}
		return false;
	}
#end
}

@:final @:unreflective @:dce
class EntityMultiSetIterator {

	public var index:Int;
	public var end:Int;
	public var data:CInt32Array;

	inline public function new(vector:EntityVector) {
		index = 0;
		end = vector.length;
		data = vector.buffer;
	}

	inline public function hasNext():Bool {
		return index != end;
	}

	@:access(ecx.Entity)
	inline public function next():Entity {
		return new Entity(data[index++]);
	}
}

