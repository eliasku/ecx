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
@:autoBuild(ecx.macro.WorldTypeBuilder.build(0))
#end
@:base
@:unreflective
class Component {

	public var entity(default, null):Int = -1;
	public var world(default, null):World;

	@:keep
	function _internal_link(entity:Int, world:World) {
		#if debug
		if(world == null) throw "bad world for linking";
		if(this.entity >= 0) throw "already linked to entity";
		#end

		this.entity = entity;
		this.world = world;
		if(world.isActive(entity)) {
			onAdded();
		}
	}

	@:keep
	function _internal_unlink() {
		#if debug
		if(world == null) throw "already not linked to entity";
		if(entity < 0) throw "linked, but has bad entity";
		#end

		if(world.isActive(entity)) {
			onRemoved();
		}
		// TODO: Invalid const
		entity = -1;
		world = null;
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

	inline public function edit():EntityView {
		#if debug
		if(world == null) throw "Component is not linked to any entity";
		if(entity < 0) throw "Bad entity";
		#end
		return world.edit(entity);
	}

	inline public function toString():String {
		return 'Component(Type: #${__getType().id}, Spec: #${__getSpec().id})';
	}
}