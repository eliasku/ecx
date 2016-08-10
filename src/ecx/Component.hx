package ecx;

import ecx.types.TypeKind;
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
@:autoBuild(ecx.macro.WorldTypeBuilder.build(0))
#end
@:base
@:unreflective
class Component {

	public var entity(default, null):Entity;
	public var world(get, never):World;

	@:keep
	function _internal_setEntity(entity:Entity) {
		if(entity != null) {
			this.entity = entity;
			if(entity.world != null) {
				onAdded();
			}
		}
		else {
			if(this.entity.world != null) {
				onRemoved();
			}
			this.entity = entity;
		}
	}

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

	inline function get_world() {
		return entity != null ? entity.world : null;
	}

	inline function toString():String {
		return 'Component(Type: #${__getType().id}, Spec: #${__getSpec().id})';
	}
}