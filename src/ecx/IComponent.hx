package ecx;

import ecx.types.ComponentType;

/**
	Base interface for implementing Component type.
**/
#if !macro
@:autoBuild(ecx.macro.ComponentBuilder.build())
#end
interface IComponent {

	function destroy(entity:Entity):Void;
	function has(entity:Entity):Bool;
	function copy(source:Entity, destination:Entity):Void;

	function getObjectSize():Int;
	function __componentType():ComponentType;
}
