package ecx;

import ecx.ds.CBitArray;
import haxe.Int32;
import ecx.ds.CArray;
import ecx.macro.ManagerMacro;
import haxe.macro.Expr;

/**
 Initialization:
 - all constructed via configuration
 - all injected
 - all initialized
 - updates
**/

#if !macro
@:autoBuild(ecx.macro.WorldTypeBuilder.build(1))
#end
@:base
@:access(ecx.Family)
class System {

	@:unreflective
	public var world(default, null):World;

	@:unreflective
	public var engine(default, null):Engine;

	@:unreflective
	var _flags:Flags = 0;

	@:unreflective
	var _families:Array<Family>;

	function initialize() {}
	function update() {}

	function onEntityAdded(entityId:Int, family:Family) {}
	function onEntityRemoved(entityId:Int, family:Family) {}

	function _inject() {}

	function _typeId():Int {
		return -1;
	}

	function _typeIndex():Int {
		return -1;
	}

	@:nonVirtual @:unreflective
	function _internal_entityChanged(entityId:Int) {
		var worldMatch:Bool = engine.worlds[entityId] == world;
		for(family in _families) {
			family._internal_entityChanged(entityId, worldMatch);
		}
	}

	macro function _family(self:ExprOf<System>, required:Array<ExprOf<Class<Component>>>):ExprOf<Array<Entity>> {
		var ids:ExprOf<Array<Int>> = ManagerMacro.ids(required);
		return macro {
			_addFamily(@:privateAccess new ecx.System.Family(this).require($ids));
		}
	}

	@:nonVirtual @:unreflective
	function _addFamily(family:Family):Array<Int> {
		if(_families == null) {
			_families = [];
			_flags = _flags | Flags.PROCESSOR;
		}
		_families.push(family);
		return family.entities;
	}

	@:nonVirtual @:unreflective @:extern
	inline function _isIdle():Bool {
		return (_flags & Flags.IDLE) != 0;
	}

	@:nonVirtual @:unreflective @:extern
	inline function _isProcessor():Bool {
		return (_flags & Flags.PROCESSOR) != 0;
	}
}

@:enum abstract Flags(Int) to Int from Int {

	// system is getting part in entities processing (check families and etc)
	var PROCESSOR = 1;

	// system is not a part of game loop, update method is not called every frame
	var IDLE = 2;

	// system only initialize something, so it will be removed after initialization
	var CONFIG = 4;
}

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.Entity)
class Family {

	public var entities(default, null):Array<Int> = [];

	var _activeBits:CBitArray;
	var _requiredComponents:CArray<CArray<Component>>;
	var _system:System;

	function new(system:System) {
		var capacity = system.engine.entityManager.capacity;
		_activeBits = new CBitArray(capacity);
		_system = system;
	}

	inline function require(requiredTypeIds:Array<Int>):Family {
		_requiredComponents = new CArray(requiredTypeIds != null ? requiredTypeIds.length : 0);
		for(i in 0..._requiredComponents.length) {
			_requiredComponents[i] = _system.engine.components[requiredTypeIds[i]];
		}
		return this;
	}

	@:nonVirtual @:unreflective
	function checkEntity(entityId:Int) {
		var rc = _requiredComponents;
		for(i in 0...rc.length) {
			if(rc[i][entityId] == null) {
				return false;
			}
		}
		return true;
	}

	// TODO: check array of entities
	@:nonVirtual @:unreflective
	function _internal_entityChanged(entityId:Int, worldMatch:Bool) {
		var fits = worldMatch && checkEntity(entityId);
		var isActive = _activeBits.get(entityId);
		if(fits && !isActive) {
			_activeBits.enable(entityId);
			entities.push(entityId);
			_system.onEntityAdded(entityId, this);
		}
		else if(!fits && isActive) {
			_activeBits.disable(entityId);
			entities.remove(entityId);
			_system.onEntityRemoved(entityId, this);
		}
	}
}
