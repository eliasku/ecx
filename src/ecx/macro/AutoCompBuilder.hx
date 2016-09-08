package ecx.macro;

#if macro
import ecx.macro.FieldsBuilder;
import ecx.macro.MacroUtil;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef Nameble = {
	var name: String;
}

typedef ComponentMacroValues = {
	var none:Expr;
	var def:Expr;
	var primitive:Bool;
	@:optional var storage:TypePath;
}

@:final
class AutoCompBuilder {

	public static function build():Array<Field> {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var localClass:ClassType = Context.getLocalClass().get();
		localClass.meta.add(":final", [], pos);

		buildDefaultConstructor(fields);

		var dataType:Type = localClass.superClass.params[0];
		var ctData = Context.toComplexType(dataType);
		var tpData = switch(ctData) {
			case ComplexType.TPath(x): x;
			default: throw "bad generic param type";
		}

		var values = getValues(dataType);
		buildCopy(fields, dataType, values);
		buildCreate(fields, dataType, values);
		buildStorageAndAllocator(fields, dataType, values);
		buildOther(fields, values, ctData);
		buildObjectSize(fields, values, ctData);

		return fields;
	}

	static function getValues(type:Type):ComponentMacroValues {
		type = Context.follow(type);
		switch(type) {
			case TInst(x, _):
				var ctData = Context.toComplexType(type);
				var tpData = switch(ctData) {
					case ComplexType.TPath(x): x;
					default: throw "bad class " + type;
				}
				if(tpData.name == "String") {
					return { none: macro null, def: macro "", primitive: true };
				}
				if(x.get().isInterface) {
					return { none: macro null, def: macro null, primitive: false };
				}
				return {none: macro null, def: macro new $tpData(), primitive: false};
			case TAbstract(x, _):
				switch(x.get().name) {
					case "Bool":
						return {
							none: macro false,
							def: macro true,
							primitive: true,
							storage: { pack: ["ecx", "ds"], name: "CBitArray" }
						};
					case "Float":
						return {
							none: macro 0.0,
							def: macro 0.0,
							primitive: true
						};
				}
				throw ("Unhandled Abstract: " + x);
			default:
				throw ("Unhandled Default value: " + type);
		}
		return { none: macro null, def: macro null, primitive: true };
	}

	static function isConstructibleType(type:Type):Bool {
		switch(type) {
			case TInst(_.get() => cls, _):
				return cls.constructor != null && !cls.isInterface;
			default:
		}
#if ecx_debug
		trace("NOT CONTRUCTABLE: " + type);
#end
		return false;
	}

	static function buildDefaultConstructor(fields:Array<Field>) {
		if (!MacroUtil.hasMethod(fields, "new")) {
			FieldsBuilder.appendMacroClass(fields, macro class New {
				inline public function new() {}
			});
		}
	}

	static function buildCreate(fields:Array<Field>, type:Type, values:ComponentMacroValues) {
		var ctData = Context.toComplexType(type);
		var tpData = switch(ctData) {
			case ComplexType.TPath(x): x;
			default: throw "bad generic param type";
		}

		FieldsBuilder.appendMacroClass(fields, macro class Create {
			inline public function create(entity:ecx.Entity):$ctData {
				var component = ${values.def};
				set(entity, component);
				return component;
			}
		});
	}

	static function buildStorageAndAllocator(fields:Array<Field>, type:Type, values:ComponentMacroValues) {
		if(values.storage == null) {
			values.storage = {
				pack: ["ecx", "ds"],
				name: "CArray",
				params: [ TPType(Context.toComplexType(type)) ]
			};
		}
		var ct = ComplexType.TPath(values.storage);
		var tp = values.storage;

		FieldsBuilder.appendMacroClass(fields, macro class StoreAndAllocate {
			public var data(default, null):$ct;
			override function __allocate() {
				data = new $tp(world.capacity);
			}
		});
	}

	static function buildCopy(fields:Array<Field>, type:Type, values:ComponentMacroValues) {
		// TODO: iterface clone?
		// TODO: value-type assignments
		var hasCopyFrom:Bool = false;
		var hasCreateInstance:Bool = false;
		switch(type) {
			case TInst(_.get() => x, _):
				var dataClass:ClassType = x;
				var dataFields = dataClass.fields.get();
				if (dataClass.isInterface) {
					hasCreateInstance = MacroUtil.hasMethodInClassFields(dataFields, "instantiate");
				}
				hasCopyFrom = MacroUtil.hasMethodInClassFields(dataFields, "copyFrom");
			default:
		}

		if(values.primitive) {
			FieldsBuilder.appendMacroClass(fields, macro class CopyValue {
				inline override public function copy(source:ecx.Entity, destination:ecx.Entity) {
					set(destination, get(source));
				}
			});
		}
		else if (hasCreateInstance && hasCopyFrom) {
			FieldsBuilder.appendMacroClass(fields, macro class CopyInstance {
				inline override public function copy(source:ecx.Entity, destination:ecx.Entity) {
					var data = get(source);
					if(data != null) {
						var newInstance = data.instantiate();
						newInstance.copyFrom(data);
						set(destination, newInstance);
					}
				}
			});
		}
		else if (hasCopyFrom) {
			FieldsBuilder.appendMacroClass(fields, macro class Clone {
				inline override public function copy(source:ecx.Entity, destination:ecx.Entity) {
					var data = get(source);
					if(data != null) {
						create(destination).copyFrom(data);
					}
				}
			});
		}
		else {
#if ecx_debug
			trace("No copy for: " + type);
#end
		}
	}

	static function buildOther(fields:Array<Field>, values:ComponentMacroValues, ctData:ComplexType) {
		FieldsBuilder.appendMacroClass(fields, macro class TempClass {
			inline public function get(entity:ecx.Entity):$ctData {
				return (data[entity.id]:$ctData);
			}

			inline public function set(entity:ecx.Entity, component:$ctData) {
				data[entity.id] = component;
			}

			inline override public function destroy(entity:ecx.Entity) {
				data[entity.id] = ${values.none};
			}

			inline override public function has(entity:ecx.Entity):Bool {
				return data[entity.id] != ${values.none};
			}
		});
	}

	static function buildObjectSize(fields:Array<Field>, values:ComponentMacroValues, ctData:ComplexType) {
		FieldsBuilder.appendMacroClass(fields, macro class ObjectSize {
			override public function getObjectSize():Int {
				return data.getObjectSize();
			}
		});
	}
}

#end