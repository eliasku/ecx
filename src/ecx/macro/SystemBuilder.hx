package ecx.macro;

#if macro

import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

class SystemBuilder {

	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();

		//MacroBuildDebug.begin();
		//MacroBuildGenerate.invoke();

		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();

		// TODO: cl & tp should be resolved from Type with Context
		var tp:TypePath = { pack: cls.pack, name: cls.name, params: [], sub: null };
		var ct:ComplexType = ComplexType.TPath(tp);

		var injExprs:Array<Expr> = [];
		addConfigurator(cls, fields, injExprs);
		makeConfigurate(fields, injExprs);
		patchUnreflective(fields);

		//MacroBuildDebug.end();

		return fields;
		return null;
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
				case FieldType.FVar(t, e) | FieldType.FProp(_, _, t, e):
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
												familyTypeParams.push(macro #if !ecx_macro_debug @:pos($v{field.pos}) #end $i{fullname});
											default:
												Context.error("Bad family type", field.pos);
										}
									}
									exprs.push(macro {
										#if !ecx_macro_debug @:pos(${field.pos}) #end $i{field.name} = _family($a{familyTypeParams});
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

	static function makeConfigurate(fields:Array<Field>, exprs:Array<Expr>) {
		if(exprs.length == 0) {
			return;
		}
		var injExpr = macro {
			function override_X__configure() {
				var __world:ecx.World = this.world;
				$b{exprs}
			}
		}
		FieldsBuilder.buildAndPush(fields, injExpr);
	}
}

#end