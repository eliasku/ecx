package ecx;

import ecx.types.ComponentType;
import ecx.types.ComponentSpec;

/**
	Component contains data for enabling behaviours for entity
	1. Data can be serialized / deserialized
	2. Data can be copied
	3. Could hold utility functionality to manipulate data
	4. Could hold reference to system to change state

	Type Id - index for base type
	Type Index - global type index
**/

#if !macro
@:autoBuild(ecx.macro.TypeBuilder.build(0))
#end
@:base
@:unreflective
class Component {

	public var entity(default, null):Entity = Entity.INVALID;
	public var world(default, null):World;

	function onAdded() {}
	function onRemoved() {}
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

	/** Component is linked to entity **/
	public var isActive(get, never):Bool;
	inline function get_isActive():Bool {
		return entity.isValid;
	}
}