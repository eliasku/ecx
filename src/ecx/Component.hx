package ecx;

import ecx.types.ComponentType;

#if !macro
@:autoBuild(ecx.macro.ComponentBuilder.build())
#end
interface Component<T> {

	function create(entity:Entity):T;
	function get(entity:Entity):T;
	function set(entity:Entity, data:T):Void;
	function remove(entity:Entity):Void;
	function has(entity:Entity):Bool;
	function copy(source:Entity, destination:Entity):Void;

	function __componentType():ComponentType;
}
