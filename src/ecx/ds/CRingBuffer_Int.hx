package ecx.ds;

@:unreflective
@:final
class CRingBuffer_Int {

    var _buffer:CArray<Int>;
    var _mask:Int;
    var _head:Int;
    var _tail:Int;

    public function new(capacity:Int) {
        _mask = capacity - 1;
        if((_mask & capacity) != 0) throw 'capacity $capacity must be power of two';
        _buffer = new CArray(capacity);
        _tail = capacity;
        _head = 0;

        for(i in 0...capacity) {
            _buffer[i] = i;
        }
    }

    public function pop():Int {
        var popAt = _head & _mask;
        _head = popAt + 1;
        return _buffer[popAt];
    }

    public function push(value:Int) {
        var placeAt = _tail & _mask;
        _tail = placeAt + 1;
        _buffer[placeAt] = value;
    }
}