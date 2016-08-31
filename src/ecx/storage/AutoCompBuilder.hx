package ecx.storage;

import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

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

	static function hasMethod(fields:Array<Nameble>, name:String):Bool {
		for (field in fields) {
			if (field.name == name) {
				return true;
			}
		}
		return false;
	}

	static function isConstructibleType(type:Type):Bool {
		switch(type) {
			case TInst(x, _):
				var cls:ClassType = x.get();
				var fields = cls.fields.get();
				return cls.constructor != null && !cls.isInterface;
			default:
		}
		trace("NOT CONTRUCTABLE: " + type);
		return false;
	}

	static function buildDefaultConstructor(fields:Array<Field>) {
		if (!hasMethod(fields, "new")) {
			var ctr = macro class New {
				inline public function new() {}
			}
			for(f in ctr.fields) {
				fields.push(f);
			}
		}
	}

	static function buildCreate(fields:Array<Field>, type:Type, values:ComponentMacroValues) {
		var create = null;
		var ctData = Context.toComplexType(type);
		var tpData = switch(ctData) {
			case ComplexType.TPath(x): x;
			default: throw "bad generic param type";
		}
//		if (isConstructibleType(type)) {
		create = macro class Create {
			inline override public function create(entity:ecx.Entity):$ctData {
				var component = ${values.def};
				set(entity, component);
				return component;
			}
		}
//		}
//		else {
//			create = macro class Create {
//				inline override public function create(entity:ecx.Entity):$ctData {
//
//				}
//			}
//		}
		for(f in create.fields) {
			fields.push(f);
		}
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

		var saa = macro class StoreAndAllocate {

			public var data(default, null):$ct;

			override function __allocate() {
				data = new $tp(world.capacity);
			}
		}
		for(f in saa.fields) {
			fields.push(f);
		}
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
					return {none: macro null, def: macro "", primitive: true};
				}
				if(x.get().isInterface) {
					return {none: macro null, def: macro null, primitive: false};
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
		return {none: macro null, def: macro null, primitive: true};
	}

	static function buildCopy(fields:Array<Field>, type:Type, values:ComponentMacroValues) {
		// TODO: iterface clone?
		// TODO: value-type assignments
		var hasCopyFrom:Bool = false;
		switch(type) {
			case TInst(x, _):
				var dataClass:ClassType = x.get();
				var dataFields = dataClass.fields.get();
				hasCopyFrom = hasMethod(dataFields, "copyFrom");
				if (dataClass.isInterface) {
					// TODO: check clone method
					hasCopyFrom = false;
					trace("copy for interface is not supported now");
				}
			default:
		}
		var copy = null;
		if(values.primitive) {
			copy = macro class Copy {
				inline override public function copy(source:ecx.Entity, destination:ecx.Entity) {
					set(destination, get(source));
				}
			}
		}
		else if (hasCopyFrom) {
			copy = macro class Copy {
				inline override public function copy(source:ecx.Entity, destination:ecx.Entity) {
					var data = get(source);
					if(data != null) {
						create(destination).copyFrom(data);
					}
				}
			}
		}
		else {
			trace("No copy for: " + type);
		}

		if(copy != null) {
			for(f in copy.fields) {
				fields.push(f);
			}
		}
	}

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

		var fs = macro class TempClass {

	inline override public function get(entity:ecx.Entity):$ctData {
		return (data[entity.id]:$ctData);
	}

	inline override public function set(entity:ecx.Entity, component:$ctData) {
		data[entity.id] = component;
	}

	inline override public function remove(entity:ecx.Entity) {
		data[entity.id] = ${values.none};
	}

	inline override public function has(entity:ecx.Entity):Bool {
		return data[entity.id] != ${values.none};
	}
};

fields = fields.concat(fs.fields);

return fields;
}
}
