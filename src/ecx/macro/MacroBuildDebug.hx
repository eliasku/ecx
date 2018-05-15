package ecx.macro;

#if macro

@:final
class MacroBuildDebug {

    static var _depth:Int = 0;

    public static function begin() {
        ++_depth;
    }

    public static function end() {
        --_depth;
    }

    public static function printSystem(data:MacroServiceData) {
        #if ecx_debug
        var prefix = indent("-", _depth - 1) + ">";
        var base = data.isBase ? "" : ' : ${data.basePath}';
        var kind = "(S)";
        trace('$prefix $kind type-${data.typeId} spec-${data.specId} ${data.path}$base');
        #end
    }

    public static function printComponent(data:MacroComponentData) {
        #if ecx_debug
        var prefix = indent("-", _depth - 1) + ">";
        var kind = "[C]";
        trace('$prefix $kind #${data.typeId} ${data.path}');
        #end
    }

    static function indent(symbol:String, amount:Int) {
        return StringTools.rpad("", symbol, amount);
    }
}

#end