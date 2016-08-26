package ecx.storage;

import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class AutoCompBuilder {

	public static function build():Array<Field> {

		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var localClass:ClassType = Context.getLocalClass().get();
		localClass.meta.add(":final", [], pos);

		var dataType:Type = localClass.superClass.params[0];
		var dataFields = switch(dataType) {
			case TInst(x, _):
				x.get().fields.get();
			case _: throw "Error";
		}

		var ctData = Context.toComplexType(dataType);
		var tpData = switch(ctData) {
			case ComplexType.TPath(x): x;
			default: throw "bad generic param type";
		}

		var hasContructor = false;
		for(f in fields) {
			if(f.name == "new") {
				hasContructor = true;
			}
		}

		var hasCopyFrom = false;
		for(dataField in dataFields) {
			if(dataField.name == "copyFrom") {
				hasCopyFrom = true;
			}
		}
		if(hasCopyFrom) {
			var copy = macro class Copy {
				inline override public function copy(source:ecx.Entity, destination:Entity) {
					var data = get(source);
					if(data != null) {
						create(destination).copyFrom(data);
					}
				}
			}

			fields = fields.concat(copy.fields);
		}

		if(!hasContructor) {
			var ctr = macro class New {
				inline public function new() {}
			}
			fields = fields.concat(ctr.fields);
		}

		var fs = macro class TempClass {

			public var data(default, null):ecx.ds.CArray<$ctData>;

	override function __allocate() {
		data = new ecx.ds.CArray<$ctData>(world.capacity);
	}

	inline override public function get(entity:ecx.Entity):$ctData {
		return (data[entity.id]:$ctData);
	}

	inline override public function set(entity:ecx.Entity, component:$ctData) {
		data[entity.id] = component;
	}

	inline override public function create(entity:ecx.Entity):$ctData {
		var component = new $tpData();
		set(entity, component);
		return component;
	}

	inline override public function remove(entity:ecx.Entity) {
		data[entity.id] = null;
	}

//	override public function copy(source:ecx.Entity, destination:ecx.Entity) {
//		var component:ecx.Component = data[source.id];
//		if (component != null) {
//			var cloned = @:privateAccess new $tpData();
//			set(destination, cloned);
//			@:privateAccess cloned.copyFrom(component);
//		}
//	}

	inline override public function has(entity:ecx.Entity):Bool {
		return data[entity.id] != null;
	}

	inline public function map():ecx.ds.CArray<$ctData> {
		return (data:ecx.ds.CArray<$ctData>);
	}
};

fields = fields.concat(fs.fields);

return fields;
}
}
