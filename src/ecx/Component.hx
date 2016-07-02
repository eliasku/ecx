package ecx;

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

	function _typeId():Int {
		return -1;
	}

	function _typeIndex():Int {
		return -1;
	}

	function _newInstance():Component {
		return null;
	}

	@:extern inline function _cast<T:Component>(clazz:Class<T>):T {
		#if cpp
		//return cpp.Pointer.addressOf(this).rawCast()[0];
		return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(this).rawCast()).value;
		#else
		return cast this;
		#end
	}

	inline function get_world() {
		return entity.world;
	}
}