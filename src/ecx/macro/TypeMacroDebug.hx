package ecx.macro;

#if macro

import ecx.types.TypeKind;

@:final
class TypeMacroDebug {

    static var _depth:Int = 0;

    public static function begin() {
        ++_depth;
    }

    public static function end() {
        --_depth;
    }

    public static function print(data:TypeMacroData) {
        #if debug
        var prefix = indent("-", _depth - 1) + ">";
        var kind = data.kind == TypeKind.COMPONENT ? "(C)" : "[S]";
        var base = data.isBase ? "" : ' : ${data.basePath}';
        trace('$prefix $kind type-${data.typeId} spec-${data.specId} ${data.path}$base');
        #end
    }

    static function indent(symbol:String, amount:Int) {
        return StringTools.rpad("", symbol, amount);
    }
}

#end