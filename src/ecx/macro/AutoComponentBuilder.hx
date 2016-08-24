package ecx.macro;

#if macro

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

@:final
class AutoComponentBuilder {

	public static function build() {

		var gt:Type = switch (Context.getLocalType()) {
			case TInst(_, [t]):
				t;
			default:
				throw false;
		}

		var gct = Context.toComplexType(gt);
		var g_tp = switch(gct) {
			case ComplexType.TPath(x):
				x;
			default:
				throw "bad generic param type";
		}

		var typeDefinition:TypeDefinition = macro class K extends ecx.storage.ComponentArray {

			public var data(default, null):ecx.ds.CArray<$gct>;

			inline public function new() {}

			override function allocate() {
				data = new ecx.ds.CArray<$gct>(world.capacity);
			}

			inline public function get(entity:ecx.Entity):$gct {
				return (data[entity.id]:$gct);
			}

			inline public function set(entity:ecx.Entity, component:$gct) {
				data[entity.id] = component;
//				#if debug
//				component.checkComponentBeforeLink(entity, world);
//				#end
				@:privateAccess component.entity = entity;
				@:privateAccess component.world = world;
				@:privateAccess component.onAdded();
			}

			inline public function create(entity:ecx.Entity):$gct {
				var component = new $g_tp();
				set(entity, component);
				return component;
			}

			inline override public function remove(entity:ecx.Entity) {
				var component:$gct = data[entity.id];
//				#if debug
//				component.checkComponentBeforeUnlink();
//				#end
				if(component != null) {
					@:privateAccess component.onRemoved();
					@:privateAccess component.entity = ecx.Entity.INVALID;
					@:privateAccess component.world = null;
					data[entity.id] = null;
				}
			}

			override public function copy(source:ecx.Entity, destination:ecx.Entity) {
				var component:ecx.Component = data[source.id];
				if(component != null) {
					var cloned = @:privateAccess new $g_tp();
					set(destination, cloned);
					@:privateAccess cloned.copyFrom(component);
				}
			}

			inline override public function has(entity:ecx.Entity):Bool {
				return data[entity.id] != null;
			}

			inline public function map():ecx.ds.CArray<$gct> {
				return (data:ecx.ds.CArray<$gct>);
			}
		};


		typeDefinition.name = "Auto_" + g_tp.name;
//var c:Expr = Context.parse("ecx.macro.SystemBuilder.build()", Context.currentPos());
//typeDefinition.meta = [
//{
//	name: ":components",
//	params: [],
//	pos: Context.currentPos()
//}
//];

FieldsBuilder.push(typeDefinition.fields, macro {
macro {
function public_Xinline_Xnew() {}
}
});

		haxe.macro.Context.defineType(typeDefinition);
		return ComplexType.TPath({name: typeDefinition.name, pack:typeDefinition.pack});
	}
}

#end