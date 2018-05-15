package ecx.macro;

#if macro

import ecx.types.ServiceType;
import ecx.types.ServiceSpec;
import ecx.types.ComponentType;
import haxe.macro.Expr;

@:final
class ClassMacroTools {

	public static function componentType<T:IComponent>(componentClass:ExprOf<Class<T>>):ExprOf<ComponentType> {
		return macro #if !ecx_macro_debug @:pos($v{componentClass.pos}) #end $componentClass.__COMPONENT;
	}

	public static function serviceType<T:Service>(serviceClass:ExprOf<Class<T>>):ExprOf<ServiceType> {
		return macro #if !ecx_macro_debug @:pos($v{serviceClass.pos}) #end $serviceClass.__TYPE;
	}

	public static function serviceSpec<T:Service>(serviceClass:ExprOf<Class<T>>):ExprOf<ServiceSpec> {
		return macro #if !ecx_macro_debug @:pos($v{serviceClass.pos}) #end $serviceClass.__SPEC;
	}

	public static function componentTypeList<T:IComponent>(componentClasses:Array<ExprOf<Class<T>>>):ExprOf<Array<ComponentType>> {
		var types = [ for(cls in componentClasses) componentType(cls) ];
		return macro $a{types};
	}
}

#end
