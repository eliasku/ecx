package ecx.macro;

import ecx.types.TypeKind;
import haxe.rtti.Meta;
import haxe.macro.Expr.ComplexType;
import ecx.macro.MacroUtil;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class WorldTypeBuilder {

	#if macro
	static var DEPTH:Int = 0;
	static var CACHE:Map<Int, Map<String, WorldTypeInfo>> = new Map();
	static var processTypesEnabled:Bool = false;

	public static function build(kind:TypeKind):Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		if(cls.isExtern) {
			cls.exclude();
			return null;
		}

		++DEPTH;

		if(!processTypesEnabled) {
			Context.onGenerate(processTypes);
			processTypesEnabled = true;
		}

		var pos = Context.currentPos();
		if(kind == TypeKind.COMPONENT) {
			cls.meta.add(":unreflective", [], Context.currentPos());
			//cls.meta.add(":final", [], Context.currentPos());
			//cls.meta.add(":keep", [], Context.currentPos());
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

		//traceCurrentType(DEPTH, typeInfo);

		var fields:Array<Field> = Context.getBuildFields();
		var fieldsExpr = macro {
			var public_Xstatic_Xinline_X__TYPE = new $tpType($typeId);
			var public_Xstatic_Xinline_X_SPEC_ID = $specId;
			function override_X__getType() { return new $tpType($typeId); }
			function override_X__getSpec() { return new $tpSpec($specId); }
		}
		var idFields = MacroUtil.buildFields(fieldsExpr);
		fields = fields.concat(idFields);

		var hasConstructor:Bool = false;
		for(field in fields) {
			if(field.name == "new") {
				hasConstructor = true;
			}
		}

		if(kind == 0 && hasConstructor) {
			var collectionTypePath = {
				pack: ["ecx", "ds"],
				name: "CArray",
				params: [TypeParam.TPType(componentType)],
				sub: null
			};
			var cloneExpr = macro {
				function override_Xpublic_X_newInstance():ecx.Component {
					return new $tp();
				}

			// TODO: typed component storage
//				function static_Xprivate_X_allocTypedArray(capacity:Int):Dynamic {
//					trace("ALLOC: " + _TYPE_ID);
//					return new $collectionTypePath(capacity);
//				}
			}

			var cloneFields = MacroUtil.buildFields(cloneExpr);
			fields = fields.concat(cloneFields);
		}

		if(kind == TypeKind.SYSTEM) {
			var injExprs:Array<Expr> = [];
			addConfigurator(cls, fields, injExprs);
			addInjectors(fields, injExprs);
			fields = makeInjectMethod(fields, injExprs);
		}
		--DEPTH;

		return fields;
	}

	static function getTypePathForType(kind:TypeKind, spec:Bool) {
		var name = (kind == TypeKind.COMPONENT ? "Component" : "System") + (spec ? "Spec" : "Type");
		return { pack: ["ecx", "types"], name: name, params: [], sub: null };
	}

	static function processTypes(types:Array<Type>) {
		var db:Type = Context.getType("ecx.types.TypeManager");
		switch(db) {
			case Type.TInst(cl, _):
				var md:MetaAccess = cl.get().meta;
				var exprs = [];
				for(kind in CACHE.keys()) {
					var map:Map<String, WorldTypeInfo> = CACHE.get(kind);
					for(ti in map) {
						exprs = exprs.concat([
							macro $v{ti.kind},
							macro $v{ti.path},
							macro $v{ti.basePath},
							macro $v{ti.specId},
							macro $v{ti.typeId}
						]);
					}
				}
				md.add("types_data", exprs, Context.currentPos());
			default:
		}
	}

	static function traceCurrentType(depth:Int, typeInfo:WorldTypeInfo) {
		var indent = repeatString("-", depth - 1);
		var kind = typeInfo.kind == TypeKind.COMPONENT ? "(C)" : "[S]";
		var base = typeInfo.path == typeInfo.basePath ? "" : ' <${typeInfo.basePath}>';
		trace('$indent> $kind ${typeInfo.path}$base #${typeInfo.typeId}');
	}

	static function addInjectors(fields:Array<Field>, exprs:Array<Expr>) {
		var injectFields:Array<Field> = [];
		var injectType:Array<String> = [];
		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, _):
					if(t != null) {
						if(field.meta != null) {
							for(m in field.meta) {
								if(m.name == ":wire") {
									injectFields.push(field);
									switch(t) {
										case ComplexType.TPath(tp):
											injectType.push(MacroUtil.getFullNameFromTypePath(tp));
										default:
											Context.error("wrong", field.pos);
									}
								}
							}
						}
						switch(t) {
							case ComplexType.TPath(tp):
								if(tp.name == "MapTo" && tp.params != null && tp.params.length == 1) {
									switch(tp.params[0]) {
										case TPType(TPath(tp)):
											var fullname = MacroUtil.getFullNameFromTypePath(tp);
											exprs.push(macro $i{field.name} = engine.mapTo($i{fullname}));
										default:
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
					$i{injectFields[i].name} = __world.get($i{injectType[i]});
				};
				exprs.push(expr);
			}
		}
	}

	static function addConfigurator(cls:ClassType, fields:Array<Field>, exprs:Array<Expr>) {
		if(cls.meta.has(":idle")) {
			exprs.push(macro {
				_flags = _flags.add(ecx.types.SystemFlags.IDLE);
			});
		}
		if(cls.meta.has(":config")) {
			exprs.push(macro {
				_flags = _flags.add(ecx.types.SystemFlags.CONFIG);
			});
		}
		for(field in fields) {
			switch(field.kind) {
				case FieldType.FVar(t, _):
					if(t != null && field.meta != null) {
						for(m in field.meta) {
							if(m.name == ":family") {
								var fieldName = field.name;
								exprs.push(macro {
									@:pos(${Context.currentPos()}) $i{field.name} = _family($a{m.params});
								});
							}
						}
					}
				default:
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
			var injFields = MacroUtil.buildFields(injExpr);
			fields = fields.concat(injFields);
		}
		return fields;
	}

	static function getTypeInfo(kind:TypeKind, cl:ClassType):WorldTypeInfo {
		var baseClass = cl;
		// Traverse up to the last non-component base
		while(!extendsBaseType(baseClass)) {
			baseClass = baseClass.superClass.t.get();
		}

		// Look up the ID, otherwise generate one
		var fullName:String = MacroUtil.getFullNameFromBaseType(cl);
		var baseFullName:String = MacroUtil.getFullNameFromBaseType(baseClass);

		var map:Map<String, WorldTypeInfo> = CACHE.get(kind);
		if(map == null) {
			map = new Map();
			CACHE.set(kind, map);
		}

		var typeInfo:WorldTypeInfo = map.get(fullName);
		if (typeInfo == null) {
			var baseTypeId = -1;
			if(baseFullName != fullName) {
				for(baseInfo in map) {
					if(baseInfo.basePath == baseFullName) {
						baseTypeId = baseInfo.typeId;
						break;
					}
				}
			}
			typeInfo = new WorldTypeInfo(kind, baseFullName, fullName, baseTypeId);
			map.set(fullName, typeInfo);
		}

		return typeInfo;
	}

	static function repeatString(str:String, count:Int) {
		var result = "";
		while(count --> 0) {
			result += str;
		}
		return result;
	}

	static function extendsBaseType(classType:ClassType) {
		var superClass = classType.superClass.t.get();
		return superClass.meta.has(":base");
	}
#end

//	public macro static function createComponents(self:ExprOf<ecx.Engine>, cap:ExprOf<Int>) {
//		var exprs:Array<Expr> = [];
//		var map:Map<String, WorldTypeInfo> = CACHE.get(0);
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

class WorldTypeInfo {

	static var NEXT_TYPE_ID:Array<Int> = [0, 0];
	static var NEXT_SPEC_ID:Array<Int> = [0, 0];

	// Base Family full name (some.foo.Bar)
	public var basePath(default, null):String;

	// Full class path (some.foo.Bar)
	public var path(default, null):String;

	// kind of type (component or system)
	public var kind(default, null):TypeKind;

	// common base type id
	public var typeId(default, null):Int;

	// specific unique type index for implementations
	public var specId(default, null):Int;

	public function new(kind:TypeKind, basePath:String, path:String, baseTypeId:Int = -1) {
		this.kind = kind;
		this.basePath = basePath;
		this.path = path;
		typeId = baseTypeId >= 0 ? baseTypeId : (NEXT_TYPE_ID[kind]++);
		specId = NEXT_SPEC_ID[kind]++;
	}
}