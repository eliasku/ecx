package ecx.macro;

#if macro

import ecx.macro.MacroUtil;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

@:final
class ServiceBuilder {

	public inline static var META_CORE:String = ":core";

	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		if(cls.isExtern) {
			cls.exclude();
			return null;
		}

		MacroBuildDebug.begin();
		MacroBuildGenerate.invoke();

		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();

		var typeInfo = getTypeInfo(cls);
		if(typeInfo != null) {
			var typeBasePath = Context.makeExpr(typeInfo.basePath, pos);
			var typePath = Context.makeExpr(typeInfo.path, pos);
			var typeId = Context.makeExpr(typeInfo.typeId, pos);
			var specId = Context.makeExpr(typeInfo.specId, pos);

			// TODO: cl & tp should be resolved from Type with Context
			var tp:TypePath = { pack: cls.pack, name: cls.name, params: [], sub: null };
			var ct:ComplexType = ComplexType.TPath(tp);

			var tpType = getTypePathForType(false);
			var tpSpec = getTypePathForType(true);

			MacroBuildDebug.printSystem(typeInfo);

			var fieldsExpr = macro {
				function override_X__serviceType() { return new $tpType($typeId); }
				function override_X__serviceSpec() { return new $tpSpec($specId); }
				var public_Xstatic_Xinline_X__TYPE = new $tpType($typeId);
				var public_Xstatic_Xinline_X__SPEC = new $tpSpec($specId);
			}
			FieldsBuilder.buildAndPush(fields, fieldsExpr);
		}

		var injExprs:Array<Expr> = [];
		addInjectors(fields, injExprs);
		makeInjectMethod(fields, injExprs);
		//patchUnreflective(fields);

		MacroBuildDebug.end();

		return fields;
	}

	static function getTypePathForType(spec:Bool) {
		var name = "Service" + (spec ? "Spec" : "Type");
		return { pack: ["ecx", "types"], name: name, params: [], sub: null };
	}

	static function addInjectors(fields:Array<Field>, exprs:Array<Expr>) {
		var injectFields:Array<Field> = [];
		var injectType:Array<String> = [];
		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, _) | FieldType.FProp(_, _, t, _):
					if(t != null) {
						switch(t) {
							case ComplexType.TPath(tp):
								switch(tp.name) {
									case "Wire":
										if(tp.params != null && tp.params.length == 1) {
											injectFields.push(field);
											switch(tp.params[0]) {
												case TPType(TPath(tp)):
													injectType.push(MacroUtil.getFullNameFromTypePath(tp));
												default:
													Context.error("wrong", field.pos);
											}
										}
										else {
											Context.error("Wire require one Service Type", field.pos);
										}
								}
							default:
						}
					}
				default:
			}
		}
		if(injectFields.length > 0) {
			for(i in 0...injectFields.length) {
				var injectField = injectFields[i];

				var expr = macro $i{injectField.name} =
					#if !ecx_macro_debug @:pos($v{injectField.pos}) #end
				__world.resolve($i{injectType[i]});

				exprs.push(expr);
			}
		}
	}

	static function makeInjectMethod(fields:Array<Field>, exprs:Array<Expr>) {
		if(exprs.length == 0) {
			return;
		}
		var injExpr = macro {
			function override_X__inject() {
				var __world:ecx.World = this.world;
				$b{exprs}
			}
		}
		FieldsBuilder.buildAndPush(fields, injExpr);
	}

	static function getTypeInfo(classType:ClassType):MacroServiceData {
		if(classType.meta.has(META_CORE)) {
			return null;
		}

		var baseClass = classType;
		// Traverse up to the last non-component base
		while(!MacroUtil.extendsMeta(baseClass, META_CORE)) {
			baseClass = baseClass.superClass.t.get();
		}

		// Look up the ID, otherwise generate one
		var fullName = MacroUtil.getFullNameFromBaseType(classType);
		var baseFullName = MacroUtil.getFullNameFromBaseType(baseClass);

		var typeData = MacroServiceCache.get(fullName);
		if(typeData != null) {
			return typeData;
		}

		var baseTypeId = MacroServiceCache.getBaseTypeId(fullName, baseFullName);
		typeData = new MacroServiceData(baseFullName, fullName, baseTypeId);
		MacroServiceCache.set(typeData);
		return typeData;
	}
}

#end