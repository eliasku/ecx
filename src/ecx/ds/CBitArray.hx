package ecx.ds;

@:final
@:unreflective
@:dce
abstract CBitArray(CInt32Array) {

    inline public function new(count:Int) {
        this = new CInt32Array(Math.ceil(count / 32));
        #if neko
        for(i in 0...this.length) {
            this[i] = 0;
        }
        #end
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

    inline public function isFalse(index:Int):Bool {
        return (this[address(index)] & mask(index)) == 0;
    }

    inline public function enableIfNot(index:Int):Bool {
        var a = address(index);
        var m = mask(index);
        var v = this[a];
        if((v & m) == 0) {
            this[a] = v | m;
            return true;
        }
        return false;
    }

    //@:pure
    inline public static function address(index:Int):Int {
        return index >>> 5;
    }

    // TODO: critical analyzer exception here
    //@:pure
    inline public static function mask(index:Int):Int {
        return 0x1 << (index & 0x1F);
    }
}
