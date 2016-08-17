package ecx.macro;

#if macro

import ecx.types.SystemType;
import ecx.types.ComponentType;
import haxe.macro.Expr;

@:final
class ClassMacroTools {

	public static function componentType<T:Component>(componentClass:ExprOf<Class<T>>):ExprOf<ComponentType> {
		return macro $componentClass.__TYPE;
	}

	public static function systemType<T:System>(systemClass:ExprOf<Class<T>>):ExprOf<SystemType> {
		return macro $systemClass.__TYPE;
	}

	public static function componentTypeList<T:Component>(componentClasslist:Array<ExprOf<Class<T>>>):ExprOf<Array<ComponentType>> {
		var types = [for(cls in componentClasslist) componentType(cls)];
		return macro $a{types};
	}

	public static function allocComponent<T:Component>(componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var tp = MacroUtil.getConstTypePath(componentClass);
		return macro @:privateAccess new $tp();
	}
}

#end
