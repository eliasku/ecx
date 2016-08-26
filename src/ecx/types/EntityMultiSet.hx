package ecx.types;

import ecx.ds.CInt32Array;

@:final @:unreflective @:dce
class EntityMultiSet {

	public var length(default, null):Int = 0;
	public var buffer(default, null):CInt32Array;
	public var changed(default, null):Bool = false;

	inline public function new() {
		buffer = new CInt32Array(16);
	}

	inline public function has(entity:Entity):Bool {
		// TODO: mod bin search
		for(i in 0...length) {
			if(buffer[i] == entity.id) {
				return true;
			}
		}
		return false;
	}

	public function place(entity:Entity) {
		if (length >= buffer.length) {
			grow();
		}
		buffer[length] = entity.id;
		++length;
		changed = true;
	}

	@:access(ecx.Entity)
	inline public function get(index:Int):Entity {
		return new Entity(buffer[index]);
	}

	public function delete(entity:Entity) {
		// TODO: mod bin search
		for (i in 0...length) {
			if (buffer[i] == entity.id) {
				buffer[i] = 0xDEADBABE;
				changed = true;
				return;
			}
		}
	}

	public function invalidate() {
		for (i in 1...length) {
			var tmp = buffer[i];
			var j = i;
			while(j > 0 && tmp < buffer[j - 1]) {
				buffer[j] = buffer[j - 1];
				--j;
			}
			buffer[j] = tmp;
		}

		var c = length - 1;
		while(c >= 0 && buffer[c] == 0xDEADBABE) {
			--c;
		}
		length = c + 1;
		changed = false;
	}

	inline public function reset() {
		length = 0;
	}

	inline public function iterator():EntityMultiSetIterator {
		return new EntityMultiSetIterator(this);
	}

	function grow() {
		var data = buffer;
		buffer = new CInt32Array(Std.int(data.length * 1.5 + 1.0));
		for (i in 0...length) {
			buffer[i] = data[i];
		}
	}
}

@:final @:unreflective @:dce
class EntityMultiSetIterator {

	public var index:Int;
	public var end:Int;
	public var data:CInt32Array;

	inline public function new(vector:EntityMultiSet) {
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

