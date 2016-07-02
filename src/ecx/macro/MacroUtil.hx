package ecx.macro;

#if macro
import haxe.macro.Type.BaseType;
import haxe.macro.Expr;

using ecx.macro.EnumTools;

class MacroUtil {

	public static function buildFields(block:Expr):Array<Field> {
		var fields:Array<Field> = [];
		var exprs:Array<Expr> = EnumTools.extract(block.expr, ExprDef.EBlock(x) => x);
		var metas = [];
		for (expr in exprs) {
			switch (expr.expr) {
				case ExprDef.EMeta(meta, e):
					metas.push(meta);
				case ExprDef.EVars(vars):
					for (v in vars) {
						fields.push({
							name: getFieldName(v.name),
							doc: null,
							access: getAccess(v.name),
							kind: FieldType.FVar(v.type, v.expr),
							pos: v.expr.pos,
							meta: metas
						});
					}
					metas = [];
				case ExprDef.EFunction(name, f):
					fields.push({
						name: getFieldName(name),
						doc: null,
						access: getAccess(name),
						kind: FieldType.FFun(f),
						pos: f.expr.pos,
						meta: metas
					});
					metas = [];
				default:
			}
		}
		return fields;
	}

	static function getAccess(name:String):Array<Access> {
		var result = [];
		for (token in name.split("_X")) {
			var access = switch (token) {
				case "public": Access.APublic;
				case "private": Access.APrivate;
				case "static": Access.AStatic;
				case "override": Access.AOverride;
				case "dynamic": Access.ADynamic;
				case "inline": Access.AInline;
				default: null;
			}
			if (access != null) {
				result.push(access);
			}
		}
		return result;
	}

	static function getFieldName(name:String):String {
		var parts = name.split("_X");
		return parts[parts.length - 1];
	}

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