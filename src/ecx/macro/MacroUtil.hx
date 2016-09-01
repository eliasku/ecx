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

	public static function extendsMeta(classType:ClassType, meta:String):Bool {
		var superClass = classType.superClass.t.get();
		return superClass.meta.has(meta);
	}

	public static function hasMethod(fields:Array<Field>, name:String):Bool {
		for(field in fields) {
			if(field.name == name) {
				return switch(field.kind) {
					case FFun(_): true;
					default: false;
				}
			}
		}
		return false;
	}

	public static function hasMethodInClassFields(fields:Array<ClassField>, name:String):Bool {
		for(field in fields) {
			if(field.name == name) {
				return switch(field.kind) {
					case FMethod(_): true;
					default: false;
				}
			}
		}
		return false;
	}

	public static function hasInterface(classType:ClassType, fullName:String) {
		for(iref in classType.interfaces) {
			if(MacroUtil.getFullNameFromBaseType(iref.t.get()) == fullName) {
				return true;
			}
		}
		return false;
	}
}

#end
