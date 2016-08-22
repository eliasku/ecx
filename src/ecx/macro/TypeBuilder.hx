package ecx.macro;

#if macro

import ecx.types.TypeKind;
import ecx.macro.MacroUtil;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

@:final
class TypeBuilder {

	public static function build(kind:TypeKind):Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		if(cls.isExtern) {
			cls.exclude();
			return null;
		}

		TypeMacroDebug.begin();
		TypeMacroGenerate.invoke();

		var pos = Context.currentPos();
		if(kind == TypeKind.COMPONENT) {
			cls.meta.add(":unreflective", [], pos);
			//cls.meta.add(":final", [], pos);
			//cls.meta.add(":keep", [], pos);
		}

		var typeInfo = getTypeInfo(kind, cls);
		var typeKind = Context.makeExpr(kind, pos);
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

		var tpType = getTypePathForType(kind, false);
		var tpSpec = getTypePathForType(kind, true);

		TypeMacroDebug.print(typeInfo);

		var fields:Array<Field> = Context.getBuildFields();
		// TODO: specId
		var fieldsExpr = macro {
			var public_Xstatic_Xinline_X__TYPE = new $tpType($typeId);
			var public_Xstatic_Xinline_X__SPEC = new $tpSpec($specId);
			function override_X__getType() { return new $tpType($typeId); }
			function override_X__getSpec() { return new $tpSpec($specId); }
		}
		var idFields = FieldsBuilder.build(fieldsExpr);
		fields = fields.concat(idFields);

		var hasConstructor:Bool = false;
		for(field in fields) {
			if(field.name == "new") {
				hasConstructor = true;
			}
		}

		if(kind == TypeKind.COMPONENT && hasConstructor) {
			var cloneExpr = macro {
				function override_Xpublic_X_newInstance():ecx.Component {
					return new $tp();
				}
			}
			fields = fields.concat(FieldsBuilder.build(cloneExpr));
		}

		if(kind == TypeKind.COMPONENT && typeInfo.isBase) {
//			var collectionTypePath = {
//				pack: ["ecx", "ds"],
//				name: "CArray",
//				params: [TypeParam.TPType(componentType)],
//				sub: null
//			};
//			trace("BAAAAASE!!");
//			var tarr = macro {
//				function static_X__init__() {
//					if(@:privateAccess ecx.types.TypeManager._newvec == null) {
//						@:privateAccess ecx.types.TypeManager._newvec = [];
//					}
//					@:privateAccess ecx.types.TypeManager._newvec[$typeId] = function(capacity:Int) {
//						return new $collectionTypePath(capacity);
//					}
//				}
//			}
//			fields = fields.concat(FieldsBuilder.build(tarr));
		}

		if(kind == TypeKind.SYSTEM) {
			var injExprs:Array<Expr> = [];
			addConfigurator(cls, fields, injExprs);
			addInjectors(fields, injExprs);
			fields = makeInjectMethod(fields, injExprs);
			patchUnreflective(fields);
		}

		TypeMacroDebug.end();

		return fields;
	}

	static function getTypePathForType(kind:TypeKind, spec:Bool) {
		var name = (kind == TypeKind.COMPONENT ? "Component" : "System") + (spec ? "Spec" : "Type");
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

	static function makeInjectMethod(fields:Array<Field>, exprs:Array<Expr>):Array<Field> {
		if(exprs.length > 0) {
			var injExpr = macro {
				function override_X_inject() {
					var __world:ecx.World = this.world;
					$b{exprs}
				}
			}
			var injFields = FieldsBuilder.build(injExpr);
			fields = fields.concat(injFields);
		}
		return fields;
	}

	static function getTypeInfo(kind:TypeKind, cl:ClassType):TypeMacroData {
		var baseClass = cl;
		// Traverse up to the last non-component base
		while(!extendsBaseType(baseClass)) {
			baseClass = baseClass.superClass.t.get();
		}

		// Look up the ID, otherwise generate one
		var fullName:String = MacroUtil.getFullNameFromBaseType(cl);
		var baseFullName:String = MacroUtil.getFullNameFromBaseType(baseClass);

		var typeData = TypeMacroCache.getType(kind, fullName);
		if(typeData != null) {
			return typeData;
		}

		var baseTypeId = TypeMacroCache.getBaseTypeId(kind, fullName, baseFullName);
		typeData = new TypeMacroData(kind, baseFullName, fullName, baseTypeId);
		TypeMacroCache.set(typeData);
		return typeData;
	}

	static function extendsBaseType(classType:ClassType) {
		var superClass = classType.superClass.t.get();
		return superClass.meta.has(":base");
	}

//	public macro static function createComponents(self:ExprOf<ecx.Engine>, cap:ExprOf<Int>) {
//		var exprs:Array<Expr> = [];
//		var map:Map<String, TypeMacroData> = CACHE.get(0);
//		for(ti in map) {
//			var p:Array<String> = ti.path.split(".");
//			var name = p.pop();
//			var typeParam = TypeParam.TPType(ComplexType.TPath({name:name, pack:p}));
//			var tp:TypePath = {name:"CArray", pack:["ecx", "ds"], params:[typeParam]};
//			//return macro @:pos(Context.currentPos())@:privateAccess new $tp();
//			var expr = macro $self.components[$v{ti.id}] = new $tp($cap + 1);
//			exprs.push(expr);
//		}
//		return macro @:pos(Context.currentPos()) $b{exprs};
//	}
}

#end