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
			grow(maxLength + 1);
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

	inline public function iterator():EntityVectorIterator {
		return new EntityVectorIterator(this);
	}

	public function getObjectSize():Int {
		return buffer.getObjectSize() + 4;
	}

	function grow(requiredLength:Int) {
		var prevBuffer = buffer;
		var newLength = prevBuffer.length;
		while(newLength < requiredLength) {
			newLength = Std.int(1.0 + newLength * 1.5);
		}
		if(newLength > prevBuffer.length) {
			buffer = new CInt32Array(newLength);
			// copy only used entities
			for (i in 0...length) {
				buffer[i] = prevBuffer[i];
			}
		}
	}
}

@:final @:unreflective @:dce
class EntityVectorIterator {

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

