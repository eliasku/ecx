package ecx.macro;

#if macro

import ecx.types.ServiceType;
import ecx.types.ServiceSpec;
import ecx.types.ComponentType;
import haxe.macro.Expr;

@:final
class ClassMacroTools {

	public static function componentType<T:Component>(componentClass:ExprOf<Class<T>>):ExprOf<ComponentType> {
		return macro $componentClass.__COMPONENT;
	}

	public static function serviceType<T:Service>(serviceClass:ExprOf<Class<T>>):ExprOf<ServiceType> {
		return macro $serviceClass.__TYPE;
	}

	public static function serviceSpec<T:Service>(serviceClass:ExprOf<Class<T>>):ExprOf<ServiceSpec> {
		return macro $serviceClass.__SPEC;
	}

	public static function componentTypeList<T:Component>(componentClasses:Array<ExprOf<Class<T>>>):ExprOf<Array<ComponentType>> {
		var types = [ for(cls in componentClasses) componentType(cls) ];
		return macro $a{types};
	}
}

#end
