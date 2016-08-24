package ecx;

import ecx.types.ComponentType;
import ecx.types.ComponentSpec;

/**
	Component is behaviour data per entity

	- Requires default constructor
	- Data can be serialized / deserialized
	- Data can be cloned / copied
	- Could contain utility functions to manipulate data
	- Could hold reference to system to change state
**/

// TODO: check default constructor at compile-time

@:unreflective
class Component {

	/** Reference to linked entity **/
	public var entity(default, null):Entity = Entity.INVALID;

	/** Reference to linked world **/
	public var world(default, null):World;

	/** Component is linked to entity **/
	public var isActive(get, never):Bool;

	/** Callback when linked to alive entity **/
	function onAdded() {}

	/** Callback when unlinked from entity **/
	function onRemoved() {}

	function copyFrom(source:Component) {}

	inline function get_isActive():Bool {
		return entity.isValid;
	}
}