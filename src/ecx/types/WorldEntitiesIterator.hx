package ecx.types;
//
//import ecx.ds.CInt32RingBuffer;
//import ecx.ds.CInt32Array;
//
//@:final @:unreflective @:dce
//class WorldEntitiesIterator {
//
//	public var index:Int;
//	public var end:Int;
//	public var buffer:CInt32Array;
//	public var mask:Int;
//
//	@:access(ecx.ds.CInt32RingBuffer)
//	inline public function new(ringBuffer:CInt32RingBuffer) {
//		index = ringBuffer._tail;
//		end = ringBuffer._head;
//		buffer = ringBuffer._buffer;
//		mask = ringBuffer._mask;
//	}
//
//	inline public function hasNext() {
//		return index != end;
//	}
//
//	@:access(ecx.Entity)
//	inline public function next():Entity {
//		var v = buffer[index++];
//		index &= mask;
//		return new Entity(v);
//	}
//}