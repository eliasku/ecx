package ecx.ds;

@:final
@:unreflective
@:dce
class Cast {

    @:extern inline public static function unsafe<TIn, TClass>(value:TIn, clazz:Class<TClass>):TClass {
        #if (cpp && haxe_ver >= 3.3)
        return (cpp.Pointer.fromRaw(cpp.Pointer.addressOf(value).rawCast()):cpp.Pointer<TClass>).value;
        #else
        return cast value;
        #end
    }

    @:unreflective // no using / generic ?
    @:extern inline public static function unsafe_T<TIn, TOut>(value:TIn):TOut {
        #if (cpp && haxe_ver >= 3.3)
        return (cpp.Pointer.fromRaw(cpp.Pointer.addressOf(value).rawCast()):cpp.Pointer<TOut>).value;
        #else
        return cast value;
        #end
    }
}
