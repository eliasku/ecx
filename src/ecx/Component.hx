package ecx;

import ecx.types.ComponentType;

#if !macro
@:autoBuild(ecx.macro.ComponentBuilder.build())
#end
interface Component {
	function remove(entity:Entity):Void;
	function has(entity:Entity):Bool;
	function copy(source:Entity, destination:Entity):Void;

	function __componentType():ComponentType;
}
