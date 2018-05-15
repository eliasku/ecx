package ecx.ds;

@:final
@:unreflective
@:dce
class Cast {

    // TODO: fix C++ dynamic_cast for the latest HXCPP

    @:extern inline public static function unsafe<TIn, TClass>(value:TIn, clazz:Class<TClass>):TClass {
//        #if (cpp && haxe_ver >= 3.3)
//        return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(value).rawCast()).value;
//        #else
        return cast value;
//        #end
    }

    @:unreflective // no using / generic ?
    @:extern inline public static function unsafe_T<TIn, TOut>(value:TIn):TOut {
//        #if (cpp && haxe_ver >= 3.3)
//        return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(value).rawCast()).value;
//        #else
        return cast value;
//        #end
    }
}
