package ecx.macro;

#if macro

import ecx.types.TypeKind;

import haxe.macro.Context;
import haxe.macro.Type;

@:final
class TypeMacroGenerate {

    static var _callbackAdded:Bool = false;

    public static function invoke() {
        if(_callbackAdded == false) {
            Context.onGenerate(process);
            _callbackAdded = true;
        }
    }

    static function process(types:Array<Type>) {
        var db:Type = Context.getType("ecx.types.TypeManager");
        var exprs = [];
        for(kind in 0...TypeKind.TOTAL) {
            var map = TypeMacroCache.getTypeMap(kind);
            for(ti in map) {
                exprs = exprs.concat([
                    macro $v{ti.kind},
                    macro $v{ti.path},
                    macro $v{ti.basePath},
                    macro $v{ti.specId},
                    macro $v{ti.typeId}
                ]);
            }
        }
        var md:MetaAccess = EnumTools.extract(db, Type.TInst(cl, _) => cl.get().meta);
        md.add("types_data", exprs, Context.currentPos());
    }

}

#end