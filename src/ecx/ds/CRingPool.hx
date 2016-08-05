package ecx.ds;
//
//class CRingPool {
//    var _buffer:CArray<Int>;
//    var _mask:Int;
//    var _head:Int;
//    var _tail:Int;
//
//    public function new(capacity:Int, allocator:TAllocator) {
//        _mask = capacity - 1;
//        if((_mask & capacity) != 0) throw 'capacity $capacity must be power of two';
//        _buffer = new CArray(capacity);
//        _tail = capacity;
//        _head = 0;
//        for(i in 0...capacity) {
//            _buffer[i] = i + 1;
//        }
//    }
//
//    public function alloc():Int {
//        var popAt = _head & _mask;
//        _head = popAt + 1;
//        var value = _buffer[popAt];
//        _buffer[popAt] = null;
//
//        // TODO: no value
//        return value;
//    }
//
//    public function free(value:Int) {
//        var placeAt = _tail & _mask;
//        _tail = placeAt + 1;
//        _buffer[placeAt] = value;
//
//        // TODO: old value
//    }
//}