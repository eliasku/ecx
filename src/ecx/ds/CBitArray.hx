package ecx.ds;

abstract CBitArray(CArray<Int>) {

    inline public function new(count:Int) {
        this = new CArray<Int>(Math.round(count / 32));
    }

    inline public function enable(index:Int) {
        this[address(index)] |= mask(index);
    }

    inline public function disable(index:Int) {
        this[address(index)] &= ~mask(index);
    }

    @:arrayAccess
    inline public function get(index:Int):Bool {
        return (this[address(index)] & mask(index)) != 0;
    }

    @:arrayAccess
    inline public function set(index:Int, value:Bool):Void {
        value ? enable(index) : disable(index);
    }

    inline public function enableIfNot(index:Int):Bool {
        var a = address(index);
        var m = mask(index);
        if((this[a] & m) == 0) {
            this[a] |= m;
            return true;
        }
        return false;
    }

    @:pure
    inline public static function address(index:Int):Int {
        return index >>> 5;
    }

    @:pure
    inline public static function mask(index:Int):Int {
        return 1 << (index & 0x1F);
    }
}
