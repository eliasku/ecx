package ecx.macro;

#if macro

import haxe.macro.Expr;

@:final
class FamilyRestGeneric {
    public static function apply():ComplexType {
        return macro : ecx.types.EntityVector;
    }
}

#end