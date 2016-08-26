package ecx.macro;

#if macro

import haxe.macro.Expr;

@:final
class FamilyRestGeneric {

    public static function apply():ComplexType {

        var tpCollection = {
            pack: ["ecx", "types"],
            name: "EntityMultiSet",
            params: []
        };

        return ComplexType.TPath(tpCollection);
    }
}

#end