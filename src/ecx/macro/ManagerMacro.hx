package ecx.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class ManagerMacro {
	public static function id<T>(cls:ExprOf<Class<T>>):ExprOf<Int> {
		return macro @:pos(Context.currentPos())$cls._TYPE_ID;
	}

	public static function ids<T>(list:Array<ExprOf<Class<T>>>):ExprOf<Array<Int>> {
		var ids:Array<ExprOf<Int>> = [];
		for(req in list) {
			ids.push(id(req));
		}
		return macro @:pos(Context.currentPos())$a{ids};
	}

	public static function alloc<T>(cls:ExprOf<Class<T>>):ExprOf<T> {
		var tp = MacroUtil.getConstTypePath(cls);
		return macro @:pos(Context.currentPos())@:privateAccess new $tp();
	}
}

#end
