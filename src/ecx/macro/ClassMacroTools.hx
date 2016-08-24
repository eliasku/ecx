package ecx.macro;

#if macro

import ecx.storage.ComponentArray;
import ecx.types.SystemType;
import ecx.types.SystemSpec;
import ecx.types.ComponentType;
import haxe.macro.Expr;

@:final
class ClassMacroTools {

	public static function componentType<T:ComponentArray>(componentClass:ExprOf<Class<T>>):ExprOf<ComponentType> {
		return macro $componentClass.__COMPONENT_TYPE;
	}

	public static function systemType<T:System>(systemClass:ExprOf<Class<T>>):ExprOf<SystemType> {
		return macro $systemClass.__TYPE;
	}

	public static function systemSpec<T:System>(systemClass:ExprOf<Class<T>>):ExprOf<SystemSpec> {
		return macro $systemClass.__SPEC;
	}

	public static function componentTypeList<T:ComponentArray>(componentClasslist:Array<ExprOf<Class<T>>>):ExprOf<Array<ComponentType>> {
		var types = [for(cls in componentClasslist) componentType(cls)];
		return macro $a{types};
	}

	public static function allocComponent<T:Component>(componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var tp = MacroUtil.getConstTypePath(componentClass);
		return macro @:privateAccess new $tp();
	}
}

#end
