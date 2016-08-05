package ecx.ds;

@:final
@:unreflective
@:native
@:dce
class Cast {

    // no using / generic ?
    @:unreflective
    @:extern inline public static function unsafe<TIn, TClass>(value:TIn, clazz:Class<TClass>):TClass {

        #if (cpp && haxe_ver >= 3.3)
        return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(value).rawCast()).value;
        #else
        return cast value;
        #end
    }
}
