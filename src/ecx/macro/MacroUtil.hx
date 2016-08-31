package ecx.macro;

#if macro

import ecx.macro.EnumTools;
import haxe.macro.Type;
import haxe.macro.Expr;

using ecx.macro.EnumTools;

@:final
class MacroUtil {

	public static function getFullNameFromBaseType(baseType:BaseType):String {
		return baseType.pack.concat([baseType.name]).join(".");
	}

	public static function getFullNameFromTypePath(typePath:TypePath):String {
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

	public static function extendsBaseMeta(classType:ClassType):Bool {
		var superClass = classType.superClass.t.get();
		return superClass.meta.has(":base");
	}

	public static function hasConstructor(fields:Array<Field>):Bool {
		for(field in fields) {
			if(field.name == "new") {
				return true;
			}
		}
		return false;
	}

	public static function pos(position:Dynamic, expr:Expr):Expr {
		#if !ecx_macro_debug
		if(position != null) {
			expr.pos = position;
		}
		#end
		return expr;
	}
}

#end
