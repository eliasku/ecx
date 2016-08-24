package ecx.storage;

import haxe.Constraints.Constructible;
import ecx.ds.CArray;

using ecx.managers.WorldDebug;

@:components
#if !macro
@:genericBuild(ecx.macro.AutoComponentBuilder.build())
#end
class AutoComponents<T:(Component, Constructible<Void->Void>)> {

	public var data(default, null):CArray<T>;

	public function new() {}

	inline public function get(entity:Entity):T {
		return null;
	}

	inline public function set(entity:Entity, component:T) {}

	inline public function create(entity:Entity):T {
		return null;
	}

	inline public function remove(entity:Entity) {}

	public function copy(source:Entity, destination:Entity) {}

	inline public function has(entity:Entity):Bool {
		return false;
	}

	inline public function map():CArray<T> {
		return null;
	}

}
