package ecx;

import ecx.ds.CArray;
import ecx.ds.CArrayIterator;
import ecx.ds.CBitArray;
import ecx.ds.CInt32RingBuffer;
import ecx.ds.Cast;
import ecx.macro.ClassMacroTools;
import ecx.managers.WorldConstructor;
import ecx.types.ComponentTable;
import ecx.types.EntityData;
import ecx.types.EntityVector;
import ecx.types.FamilyData;
import haxe.macro.Expr.ExprOf;

#if ecx_debug
using ecx.managers.WorldDebug;
#end

@:final @:dce @:unreflective
@:access(ecx.System, ecx.Family, ecx.Entity)
class World {

	// Mapping: (type, entity) => component
	public var components(default, null):ComponentTable;

	// Identifier of this world
	public var id(default, null):Int;

	/**
		Maximum amount of entities including invalid/reserved.

		Capacity will be rounded to power-of-two value plus one.
		For requested capacity 3 will be allocated:
		capacity = nearestPOT(3 - 1) + 1 = 3.
		For capacity = 5 we have set of valid entities {1, 2, 3, 4} and one invalid is 0
	**/
	public var capacity(default, null):Int;
	public var used(default, null):Int = 0;
	public var available(get, never):Int;

	// lookup for all systems
	var _services:CArray<Service>;

	// all systems sorted by priority
	var _orderedServices:CArray<Service>;

	// only active systems (not idle)
	var _systems:CArray<System>;

	// systems with families
	var _processors:CArray<System>;

	var _families:CArray<FamilyData>;

	var _changedVector:EntityVector;
	var _removedVector:EntityVector;

	var _pool:CInt32RingBuffer;

	// entity => entity wrapper
	var _mapToData:CArray<EntityData>;

	// Flags
	var _aliveMask:CBitArray;
	var _activeMask:CBitArray;
	var _changedMask:CBitArray;
	var _removedMask:CBitArray;

	function new(id:Int, config:WorldConfig, capacity:Int) {
		this.id = id;
		WorldConstructor.construct(this, capacity, config);
	}

	macro public function resolve<T:Service>(self:ExprOf<World>, serviceClass:ExprOf<Class<T>>):ExprOf<T> {
		var serviceType = ClassMacroTools.serviceType(serviceClass);
		return macro {
			var tmp = @:privateAccess $self._services[$serviceType.id];
			ecx.ds.Cast.unsafe(tmp, $serviceClass);
		};
	}

	public function create():Entity {
		var entity = allocNextEntity();
		_aliveMask.enable(entity.id);
		_activeMask.enable(entity.id);
		return entity;
	}

	/** Useful for prefabs **/
	public function createPassive():Entity {
		var entity = allocNextEntity();
		_aliveMask.enable(entity.id);
		return entity;
	}

	public function clone(source:Entity):Entity {
		var entity = create();
		var componentsByType = components;
		for(typeId in 0...componentsByType.length) {
			componentsByType[typeId].copy(source, entity);
		}
		commit(entity);
		return entity;
	}

	public function delete(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		#end
		if(_removedMask.enableIfNot(entity.id)) {
			_removedVector.place(entity);
		}
	}

	public function invalidate() {
		#if ecx_debug
		lockFamilies();
		#end

		if(_removedVector.length > 0 || _changedVector.length > 0) {
			deleteEntities();
			changeEntities();
			updateFamilyVectors();
		}

		#if ecx_debug
		guardFamilies();
		unlockFamilies();
		#end
	}

	public function activate(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		if(_activeMask.get(entity.id)) throw 'This entity is already active';
		#end
		_activeMask.enable(entity.id);
		_internal_entityChanged(entity);
	}

	public function deactivate(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		if(!_activeMask.get(entity.id)) throw "This entity is already inactive";
		#end
		_activeMask.disable(entity.id);
		_internal_entityChanged(entity);
	}

//	macro public function componentArray<T:(Component<Dynamic>, Service)>(self:ExprOf<World>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
//		return macro cast @:privateAccess $self._services[componentClass.__TYPE.id];
//	}

	inline public function getEntity(id:Int):Entity {
		return @:privateAccess new Entity(id);
	}

	inline public function isActive(entity:Entity):Bool {
		return _activeMask.get(entity.id);
	}

	inline public function checkAlive(entity:Entity):Bool {
		return _aliveMask.get(entity.id);
	}

	public function toString():String {
		return 'World #$id';
	}

//	inline public function hasComponent(entity:Entity, type:ComponentType):Bool {
//		return components[type.id].has(entity);
//	}
//
//	public function removeComponent(entity:Entity, type:ComponentType) {
//		var entityToComponent:Component<Dynamic> = components[type.id];
//		entityToComponent.remove(entity);
//		if(isActive(entity)) {
//			_internal_entityChanged(entity);
//		}
//	}

	public function clearComponents(entity:Entity) {
		var componentsData = components;
		for(typeId in 0...componentsData.length) {
			var component = componentsData[typeId];
			if(component.has(entity)) {
				componentsData[typeId].remove(entity);
			}
		}
		if(isActive(entity)) {
			_internal_entityChanged(entity);
		}
	}

	inline public function commit(entity:Entity) {
		if(isActive(entity)) {
			_internal_entityChanged(entity);
		}
	}

	/** Iterator for *active* systems ordered by priority **/
	inline public function systems():CArrayIterator<System> {
		return new CArrayIterator<System>(_systems);
	}

	function allocNextEntity():Entity {
		#if ecx_debug
		if(used >= capacity) throw 'Out of entities, max allowed $capacity';
		#end

		++used;
		return new Entity(_pool.pop());
	}

	inline function get_available():Int {
		return capacity - used;
	}

	@:access(ecx.types.FamilyData)
	function deleteEntities() {
		var entities = _removedVector;
		var locPool = _pool;
		var locRemovedFlags = _removedMask;
		var locActiveFlags = _activeMask;
		var locAliveMask = _aliveMask;
		var families = _families;
		var i = 0;
		while(i < entities.length) {
			var tail = entities.length;
			while(i < tail) {
				var entity = entities.get(i);

				// Need to remove entities from families before deletion and notify systems
				for(j in 0...families.length) {
					families.get(j).__disableEntity(entity);
				}

				clearComponents(entity);
				locActiveFlags.disable(entity.id);
				locAliveMask.disable(entity.id);
				locRemovedFlags.disable(entity.id);
				locPool.push(entity.id);
				++i;
			}
		}

		var count = entities.length;
		used -= count;
		#if ecx_debug
		if(used < 0) throw "No way!";
		//if(startLength != removeList.length) throw "removing while removing";
		#end
		entities.reset();
	}

	@:access(ecx.types.FamilyData)
	function changeEntities() {
		var entities = _changedVector;
		var changedFlags = _changedMask;
		var activeFlags = _activeMask;
		var aliveMask = _aliveMask;
		var families = _families;
		var startLength = entities.length;
		var familiesTotal = families.length;
		if(entities.length > 0) {
			var i = 0;
			var end = entities.length;
			while (i < end) {
				var entity = entities.get(i);
				var alive = aliveMask.get(entity.id);
				if(alive) {
					var active = activeFlags.get(entity.id);
					if(active) {
						for(j in 0...familiesTotal) {
							families.get(j).__change(entity);
						}
					}
					else {
						for(j in 0...familiesTotal) {
							families.get(j).__disableEntity(entity);
						}
					}
				}
				changedFlags.disable(entity.id);
				++i;
			}
			#if ecx_debug
			if(startLength != entities.length) throw "update while updating";
			#end
			entities.reset();
		}
	}

	@:access(ecx.types.FamilyData)
	function updateFamilyVectors() {
		for(i in 0..._families.length) {
			var family = _families.get(i);
			if(family.changed) {
				family.__invalidate();
			}
		}
	}

	function _internal_entityChanged(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		#end
		if(_changedMask.enableIfNot(entity.id)) {
			_changedVector.place(entity);
		}
	}
}
