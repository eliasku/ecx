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

	function onEntityAdded(entity:Entity, family:Family) {}
	function onEntityRemoved(entity:Entity, family:Family) {}

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
	function _addFamily(family:Family):Array<Entity> {
		if(_families == null) {
			_families = [];
			_flags = _flags | Flags.PROCESSOR;
		}
		_families.push(family);
		return family.entities;
	}

//	@:nonVirtual @:unreflective @:extern
//	inline function _cast<T:System>(clazz:Class<T>):T {
//		#if cpp
//		//return cpp.Pointer.addressOf(this).rawCast()[0];
//		return cpp.Pointer.fromRaw(cpp.Pointer.addressOf(this).rawCast()).value;
//		#else
//		return cast this;
//		#end
//	}

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

	// TODO: system only initialize something, so it will be removed after initialization
	var CONFIG = 4;
}

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.Entity)
class Family {

	var _componentsByType:CArray<CArray<Component>>;
	var _entityMap:CArray<Entity>;
	public var system(default, null):System;
	public var entities(default, null):Array<Entity> = [];
	public var activeBits(default, null):CBitArray;

	var _required:Array<Int>;

	function new(system:System) {
		activeBits = new CBitArray(system.world.engine.edb.capacity + 1);
		this.system = system;
		_componentsByType = system.engine.components;
		_entityMap = system.engine.entities;
	}

	inline function require(required:Array<Int>):Family {
		_required = required;
		return this;
	}

	@:nonVirtual @:unreflective
	function checkEntity(entityId:Int) {
		if(_required != null) {
			var componentsByType = _componentsByType;
			for(requiredId in _required) {
				if(componentsByType[requiredId][entityId] == null) {
					return false;
				}
			}
		}
		return true;
	}

	// TODO: check array of entities
	@:nonVirtual @:unreflective
	function _internal_entityChanged(entityId:Int, worldMatch:Bool) {
		var fits = worldMatch && checkEntity(entityId);
		var entity = _entityMap[entityId];
		//var address = entityId >>> 5;
		//var mask = 1 << (entityId & 0x1F);
		var isActive = activeBits.get(entityId);
		if(fits && !isActive) {
			activeBits.enable(entityId);
			//this.active[address] |= mask;
			entities.push(entity);
			system.onEntityAdded(entity, this);
		}
		else if(!fits && isActive) {
			activeBits.disable(entityId);
			//this.active[address] &= ~mask;
			entities.remove(entity);
			system.onEntityRemoved(entity, this);
		}
	}
}
