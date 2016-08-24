package ecx.storage;

import ecx.ds.CArray;

#if !macro
@:autoBuild(ecx.storage.AutoCompBuilder.build())
#end
@:remove
interface AutoComp<T> {

	var data(default, null):CArray<T>;
	function get(entity:Entity):T;
	function set(entity:Entity, component:T):Void;
	function create(entity:Entity):T;
	function remove(entity:Entity):Void;
	function copy(source:Entity, destination:Entity):Void;
	function has(entity:Entity):Bool;
}
