package ecx.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Type;

@:final
class MacroBuildGenerate {

    static var _callbackAdded:Bool = false;

    public static function invoke() {
        if(_callbackAdded == false) {
            Context.onGenerate(process);
            _callbackAdded = true;
        }
    }

    static function process(types:Array<Type>) {
        var type:Type = Context.getType("ecx.types.TypeManager");
        var metaAccess:MetaAccess = EnumTools.extract(type, Type.TInst(cl, _) => cl.get().meta);

        var exprs = [];
        for(systemData in MacroServiceCache.cache) {
            exprs.push(macro $v{systemData.path});
            exprs.push(macro $v{systemData.basePath});
            exprs.push(macro $v{systemData.typeId});
            exprs.push(macro $v{systemData.specId});
        }
        metaAccess.add("systems", exprs, Context.currentPos());
//
//        var exprs = [];
//        for(componentData in MacroComponentCache.cache) {
//            exprs.push(macro $v{componentData.path});
//            exprs.push(macro $v{componentData.basePath});
//            exprs.push(macro $v{componentData.typeId});
//            exprs.push(macro $v{componentData.specId});
//        }
//        metaAccess.add("components", exprs, Context.currentPos());
    }
}

#end