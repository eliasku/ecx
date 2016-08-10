package ecx.macro;

#if macro

import ecx.types.SystemType;
import ecx.types.ComponentType;
import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class ManagerMacro {
	public static function componentType<T:Component>(cls:ExprOf<Class<T>>):ExprOf<ComponentType> {
		return macro @:pos(Context.currentPos())$cls.__TYPE;
	}

	public static function systemType<T:System>(cls:ExprOf<Class<T>>):ExprOf<SystemType> {
		return macro @:pos(Context.currentPos())$cls.__TYPE;
	}

//	public static function id<T>(cls:ExprOf<Class<T>>):ExprOf<Int> {
//		return macro @:pos(Context.currentPos())$cls._TYPE_ID;
//	}

	public static function componentTypeList<T:Component>(list:Array<ExprOf<Class<T>>>):ExprOf<Array<ComponentType>> {
		var types:Array<ExprOf<ComponentType>> = [];
		for(cls in list) {
			types.push(componentType(cls));
		}
		return macro @:pos(Context.currentPos())$a{types};
	}

	public static function alloc<T>(cls:ExprOf<Class<T>>):ExprOf<T> {
		var tp = MacroUtil.getConstTypePath(cls);
		return macro @:pos(Context.currentPos())@:privateAccess new $tp();
	}
}

#end
