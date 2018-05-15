package ecx.ds;

/** https://github.com/zeliard/Dispatcher/blob/master/JobDispatcher/ObjectPool.h **/

@:unreflective
@:final
class CInt32RingBuffer {

    public var length(get, never):Int;

    var _buffer:CInt32Array;
    var _mask:Int;
    var _head:Int = 0;
    var _tail:Int = 0;

    public function new(capacity:Int) {
        _mask = capacity - 1;
        #if ecx_debug
        if(capacity == 0) throw 'non-zero capacity is required';
        if((_mask & capacity) != 0) throw 'capacity $capacity must be power of two';
        #end
        _buffer = new CInt32Array(capacity);
    }

    inline public function set(index:Int, value:Int) {
        _buffer[index] = value;
    }

    public function pop():Int {
        var popAt = _head;
        _head = popAt + 1;
        _head &= _mask;
        return _buffer[popAt];
    }

    public function push(value:Int) {
        var placeAt = _tail;
        _buffer[placeAt] = value;
        ++placeAt;
        _tail = placeAt & _mask;
    }

    public function getObjectSize():Int {
        return _buffer.getObjectSize() + 16;
    }

    inline function get_length() {
        return _buffer.length;
    }
}