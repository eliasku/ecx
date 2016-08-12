package ecx.macro;

#if macro

import ecx.macro.EnumTools;
import haxe.macro.Type.BaseType;
import haxe.macro.Expr;

using ecx.macro.EnumTools;

@:final
class MacroUtil {

	public static function getConstTypePath<T>(cls:ExprOf<Class<T>>):TypePath {
		var path:Array<String> = EnumTools.extract(cls.expr, EConst(CIdent(x)) => x.split("."));
		var name = path[path.length - 1];
		path.splice(path.length - 1, 1);
		return { pack: path, name: name };
	}

	public static function getFullNameFromBaseType(baseType:BaseType) {
		return baseType.pack.concat([baseType.name]).join(".");
	}

	public static function getFullNameFromTypePath(typePath:TypePath) {
		return typePath.pack.concat([typePath.name]).join(".");
	}
}

#end