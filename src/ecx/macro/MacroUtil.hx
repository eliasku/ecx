package ecx.macro;

#if macro

import ecx.macro.EnumTools;
import haxe.macro.Type.BaseType;
import haxe.macro.Expr;

using ecx.macro.EnumTools;

@:final
class MacroUtil {

	public static function getFullNameFromBaseType(baseType:BaseType) {
		return baseType.pack.concat([baseType.name]).join(".");
	}

	public static function getFullNameFromTypePath(typePath:TypePath) {
		return typePath.pack.concat([typePath.name]).join(".");
	}

	public static function getConstTypePath<T>(cls:ExprOf<Class<T>>):TypePath {
		var path = getIdentPath(cls, []);
		var name = path.pop();
		return { name: name, pack: path };
	}

	static function getIdentPath(expr:Expr, path:Array<String>):Array<String> {
		switch (expr.expr) {
			case EConst(CIdent(name)):
				path.push(name);
			case EField(childExpr, name):
				getIdentPath(childExpr, path);
				path.push(name);
			default:
				throw "unexcepted expr";
		}
		return path;
	}
}

#end
