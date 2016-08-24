package ecx.storage;

import ecx.macro.FieldsBuilder;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class AutoCompBuilder {

	public static function build():Array<Field> {

		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var localClass:ClassType = Context.getLocalClass().get();
		var dataType:Type;
		for (impl in localClass.interfaces) {
			if (impl.t.get().name == "AutoComp") {
				dataType = impl.params[0];
				break;
			}
		}

		var ctData = Context.toComplexType(dataType);
		var tpData = switch(ctData) {
			case ComplexType.TPath(x): x;
			default: throw "bad generic param type";
		}

		var fs = macro class TempClass {

			public var data(default, null):ecx.ds.CArray<$ctData>;

	inline public function new() {}

	override function allocate() {
		data = new ecx.ds.CArray<$ctData>(world.capacity);
	}

	inline public function get(entity:ecx.Entity):$ctData {
		return (data[entity.id]:$ctData);
	}

	inline public function set(entity:ecx.Entity, component:$ctData) {
		data[entity.id] = component;
//				#if debug
//				component.checkComponentBeforeLink(entity, world);
//				#end
		@:privateAccess component.entity = entity;
		@:privateAccess component.world = world;
		@:privateAccess component.onAdded();
	}

	inline public function create(entity:ecx.Entity):$ctData {
		var component = new $tpData();
		set(entity, component);
		return component;
	}

	inline override public function remove(entity:ecx.Entity) {
		var component:$ctData = data[entity.id];
//				#if debug
//				component.checkComponentBeforeUnlink();
//				#end
		if (component != null) {
			@:privateAccess component.onRemoved();
			@:privateAccess component.entity = ecx.Entity.INVALID;
			@:privateAccess component.world = null;
			data[entity.id] = null;
		}
	}

	override public function copy(source:ecx.Entity, destination:ecx.Entity) {
		var component:ecx.Component = data[source.id];
		if (component != null) {
			var cloned = @:privateAccess new $tpData();
			set(destination, cloned);
			@:privateAccess cloned.copyFrom(component);
		}
	}

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
