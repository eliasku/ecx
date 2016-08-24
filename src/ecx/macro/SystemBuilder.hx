package ecx.macro;

#if macro

import ecx.macro.MacroUtil;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

@:final
class SystemBuilder {

	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		if(cls.isExtern) {
			cls.exclude();
			return null;
		}

		trace("----- " + cls.name);
		if(cls.meta.has(":generic")) {
			trace("GENERIC: " + cls.name);
			cls.meta.add(":autoBuild", [
				macro ecx.macro.SystemBuilder.build(1)
			], cls.pos);
//			//var t = Context.getType(cls.name);
//			return null;
		}

		MacroBuildDebug.begin();
		MacroBuildGenerate.invoke();

		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();

		var typeInfo = getTypeInfo(cls);
		var typeBasePath = Context.makeExpr(typeInfo.basePath, pos);
		var typePath = Context.makeExpr(typeInfo.path, pos);
		var typeId = Context.makeExpr(typeInfo.typeId, pos);
		var specId = Context.makeExpr(typeInfo.specId, pos);
		var tp = {
			pack: cls.pack,
			name: cls.name,
			params: [],
			sub: null
		};
		var componentType:ComplexType = ComplexType.TPath(tp);

		var tpType = getTypePathForType(false);
		var tpSpec = getTypePathForType(true);

		MacroBuildDebug.printSystem(typeInfo);


		var fieldsExpr = macro {
			function override_X__getType() { return new $tpType($typeId); }
			function override_X__getSpec() { return new $tpSpec($specId); }
		}
		FieldsBuilder.push(fields, fieldsExpr);

		if(!cls.meta.has(":generic")) {
			var staticTypesExpr = macro {
				var public_Xstatic_Xinline_X__TYPE = new $tpType($typeId);
				var public_Xstatic_Xinline_X__SPEC = new $tpSpec($specId);
			}
			FieldsBuilder.push(fields, staticTypesExpr);
		}

		var compData = getComponentType(cls);
		if(compData != null) {
			MacroBuildDebug.printComponent(compData);
			var compTypeId = Context.makeExpr(compData.typeId, pos);
			var compExprs = macro {
				function override_X__componentType() { return new ecx.types.ComponentType($compTypeId); }
			}
			FieldsBuilder.push(fields, compExprs);

			if(!cls.meta.has(":generic")) {
				var staticCompExprs = macro {
					var public_Xstatic_Xinline_X__COMPONENT_TYPE = new ecx.types.ComponentType($compTypeId);
				}
				FieldsBuilder.push(fields, staticCompExprs);
			}
		}

		var injExprs:Array<Expr> = [];
		addConfigurator(cls, fields, injExprs);
		addInjectors(fields, injExprs);
		makeInjectMethod(fields, injExprs);
		patchUnreflective(fields);

		MacroBuildDebug.end();

		return fields;
	}

	static function getTypePathForType(spec:Bool) {
		var name = "System" + (spec ? "Spec" : "Type");
		return { pack: ["ecx", "types"], name: name, params: [], sub: null };
	}

	static function addInjectors(fields:Array<Field>, exprs:Array<Expr>) {
		var injectFields:Array<Field> = [];
		var injectType:Array<String> = [];
		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, _):
					if(t != null) {
						switch(t) {
							case ComplexType.TPath(tp):
								switch(tp.name) {
									case "MapTo":
										if(tp.params != null && tp.params.length == 1) {
											switch(tp.params[0]) {
												case TPType(TPath(tp)):
													var fullname = MacroUtil.getFullNameFromTypePath(tp);
													exprs.push(macro $i{field.name} = world.mapTo($i{fullname}));
												default:
													Context.error("wrong", field.pos);
											}
										}
										else {
											Context.error("MapTo require one Component Type", field.pos);
										}

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
											Context.error("Wire require one System Type", field.pos);
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
				var expr = macro {
					$i{injectFields[i].name} = __world.resolve($i{injectType[i]});
				};
				exprs.push(expr);
			}
		}
	}

	static function addConfigurator(cls:ClassType, fields:Array<Field>, exprs:Array<Expr>) {
		var updateField = searchUpdate(fields);
		if(updateField == null) {
			exprs.push(macro {
				_flags = _flags.add(ecx.types.SystemFlags.IDLE);
			});
		}
		if(cls.meta.has(":config")) {
			exprs.push(macro {
				_flags = _flags.add(ecx.types.SystemFlags.CONFIG);
			});
		}
		var hasUpdate:Bool = false;
		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, e):
					switch(t) {
						case ComplexType.TPath(tp):
							if(tp.name == "Family") {
								if(e != null) {
									Context.error("Remove initializer, family binding will be created at compile-time", field.pos);
								}
								var params:Array<TypeParam> = tp.params;
								if(params == null || params.length == 0) {
									Context.error("Family required at least one component Class", field.pos);
								}
								else {
									var familyTypeParams = [];
									for(param in params) {
										switch(param) {
											case TypeParam.TPType(TPath(componentTypePath)):
												var fullname = MacroUtil.getFullNameFromTypePath(componentTypePath);
												familyTypeParams.push(macro $i{fullname});
											default:
												Context.error("Bad family type", field.pos);
										}
									}
									exprs.push(macro {
										@:pos(${field.pos}) $i{field.name} = _family($a{familyTypeParams});
									});
								}
							}
						default:
					}
				default:
			}
		}
	}

	static function searchUpdate(fields:Array<Field>):Null<Field> {
		for(field in fields) {
			if(field.name == "update") {
				return EnumTools.extract(field.kind, FieldType.FFun(_) => field);
			}
		}
		return null;
	}

	static function patchUnreflective(fields:Array<Field>) {
		for(field in fields) {
			switch(field.name) {
				case "update":// | "initialize" | "onEntityAdded" | "onEntityRemoved":
					if(field.meta == null) {
						field.meta = [];
					}
					field.meta.push({
						name: ":unreflective",
						pos: field.pos
					});
			}
		}
	}

	static function makeInjectMethod(fields:Array<Field>, exprs:Array<Expr>) {
		if(exprs.length == 0) {
			return;
		}
		var injExpr = macro {
			function override_X_inject() {
				var __world:ecx.World = this.world;
				$b{exprs}
			}
		}
		FieldsBuilder.push(fields, injExpr);
	}

	static function getTypeInfo(classType:ClassType):MacroSystemData {
		var baseClass = classType;
		// Traverse up to the last non-component base
		while(!MacroUtil.extendsBaseMeta(baseClass)) {
			baseClass = baseClass.superClass.t.get();
		}

		// Look up the ID, otherwise generate one
		var fullName = MacroUtil.getFullNameFromBaseType(classType);
		var baseFullName = MacroUtil.getFullNameFromBaseType(baseClass);

		var typeData = MacroSystemCache.get(fullName);
		if(typeData != null) {
			return typeData;
		}

		var baseTypeId = MacroSystemCache.getBaseTypeId(fullName, baseFullName);
		typeData = new MacroSystemData(baseFullName, fullName, baseTypeId);
		MacroSystemCache.set(typeData);
		return typeData;
	}

	static function getComponentType(classType:ClassType):MacroComponentData {
		var baseClass = classType;
		if(classType.meta.has(":components")) {
			return null;
		}
		// Traverse up to the last non-component base
		while(baseClass.superClass != null) {
			baseClass = baseClass.superClass.t.get();
			if(baseClass.meta.has(":components")) {
				// Look up the ID, otherwise generate one
				var fullName = MacroUtil.getFullNameFromBaseType(classType);
				var compData = MacroComponentCache.get(fullName);
				if(compData != null) {
					return compData;
				}
				compData = new MacroComponentData(fullName);
				MacroComponentCache.set(compData);
				return compData;
			}
		}

		return null;

	}

	static function extendsBaseType(classType:ClassType) {
		var superClass = classType.superClass.t.get();
		return superClass.meta.has(":base");
	}
}

#end