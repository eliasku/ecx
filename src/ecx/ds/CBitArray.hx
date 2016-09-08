package ecx.ds;

@:final
@:unreflective
@:dce
abstract CBitArray(CInt32Array) {

    inline public static var BITS_PER_ELEMENT:Int = 32;
    inline public static var BIT_SHIFT:Int = 5;
    inline public static var BIT_MASK:Int = 0x1F;

    inline public function new(count:Int) {
        this = new CInt32Array(Math.ceil(count / BITS_PER_ELEMENT));
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
        this[address(index)] &= ~(mask(index));
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

    inline public function getObjectSize():Int {
        return this.length << 2;
    }

    // TODO: @:pure after haxe 3.3.0 release
    inline public static function address(index:Int):Int {
        return index >>> BIT_SHIFT;
    }

    // TODO: @:pure after haxe 3.3.0 release
    inline public static function mask(index:Int):Int {
        return 0x1 << (index & BIT_MASK);
    }
}
