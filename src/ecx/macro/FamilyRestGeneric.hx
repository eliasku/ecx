package ecx.macro;

#if macro

import haxe.macro.Expr;

@:final
class FamilyRestGeneric {

    public static function apply():ComplexType {

        var tpEntity = {
            pack: ["ecx"],
            name: "Entity"
        };

        var tpCollection = {
            pack: ["ecx", "ds"],
            name: "CVector",
            params: [TypeParam.TPType(ComplexType.TPath(tpEntity))]
        };

        return ComplexType.TPath(tpCollection);
    }
}

#end