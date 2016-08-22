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

#if !macro
@:autoBuild(ecx.macro.TypeBuilder.build(0))
#end
@:base
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

	/** Lock linked entity for editing **/
	inline public function edit():EntityView {
		#if debug
		if(world == null) throw "Component is not linked to any entity";
		if(!entity.isValid) throw "Bad entity";
		#end
		return world.edit(entity);
	}

	inline public function toString():String {
		return 'Component(Type: #${__getType().id}, Spec: #${__getSpec().id})';
	}

	function copyFrom(source:Component) {}

	function __getType():ComponentType {
		return ComponentType.INVALID;
	}

	function __getSpec():ComponentSpec {
		return ComponentSpec.INVALID;
	}

	function _newInstance():Component {
		return null;
	}

	inline function get_isActive():Bool {
		return entity.isValid;
	}
}