package ecx;

import ecx.types.ComponentType;
import ecx.types.ComponentTable;
import ecx.ds.CArray;
import ecx.ds.CArrayIterator;
import ecx.ds.CBitArray;
import ecx.ds.CInt32RingBuffer;
import ecx.ds.Cast;
import ecx.macro.ClassMacroTools;
import ecx.managers.WorldConstructor;
import ecx.types.EntityData;
import ecx.types.EntityVector;
import ecx.types.FamilyData;
import haxe.macro.Expr.ExprOf;

#if ecx_debug
using ecx.managers.WorldDebug;
#end

/**
	World manages entities, components and services
**/
@:final @:dce @:unreflective
@:access(ecx.System, ecx.Family, ecx.Entity)
class World {

	/**
		Identifier of this world
 	**/
	public var id(default, null):Int;

	/**
		Maximum amount of entities including invalid/reserved.

		Capacity will be rounded to power-of-two value plus one.
		For requested capacity 3 will be allocated:
		capacity = nearestPOT(3 - 1) + 1 = 3.
		For capacity = 5 we have set of valid entities {1, 2, 3, 4} and one invalid is 0
	**/
	public var capacity(default, null):Int;

	/** Count of alive entities **/
	public var used(default, null):Int = 0;

	/** Count of available entities in pool **/
	public var available(get, never):Int;

	// components
	var _components:ComponentTable;

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
	//var _mapToData:CArray<EntityData>;

	// Flags
	var _aliveMask:CBitArray;
	var _activeMask:CBitArray;
	var _changedMask:CBitArray;
	var _removedMask:CBitArray;

	function new(id:Int, config:WorldConfig, capacity:Int) {
		this.id = id;
		WorldConstructor.construct(this, capacity, config);
	}

	/**
		Get registered `Service` by compile-time `Class<Service>` constant.
		Note: macro generates unsafe-cast to `T:Service`.
	**/
	macro public function resolve<T:Service>(self:ExprOf<World>, serviceClass:ExprOf<Class<T>>):ExprOf<T> {
		var serviceType = ClassMacroTools.serviceType(serviceClass);
		return macro {
			var tmp = @:privateAccess $self._services[$serviceType.id];
			ecx.ds.Cast.unsafe(tmp, $serviceClass);
		};
	}

	/**
		Resolve `IComponent` service by run-time `ComponentType`
	**/
	inline public function getComponentService(componentType:ComponentType):IComponent {
		return _components[componentType.id];
	}

	/**
		Return new active entity (which will be marked as changed).
	**/
	public function create():Entity {
		var entity = allocNextEntity();
		_aliveMask.enable(entity.id);
		_activeMask.enable(entity.id);
		markEntityAsChanged(entity);
		return entity;
	}

	/**
		Returns new passive entity.
	**/
	public function createPassive():Entity {
		var entity = allocNextEntity();
		_aliveMask.enable(entity.id);
		return entity;
	}

	/**
		Creates active entity and clone data from `source` entity.
	**/
	public function clone(source:Entity):Entity {
		var entity = create();
		var componentsByType = _components;
		for(typeId in 0...componentsByType.length) {
			componentsByType[typeId].copy(source, entity);
		}
		commit(entity);
		return entity;
	}

	/**
		Entity will be destroyed on next world invalidation
	**/
	public function destroy(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		#end
		if(_removedMask.enableIfNot(entity.id)) {
			_removedVector.place(entity);
		}
	}

	/** DEPRECATED! Use `destroy()` instead **/
	@:deprecated("Use destroy() instead")
	public function delete(entity:Entity) {
		destroy(entity);
	}

	/**
		Performs entities destroying, commits and update families
	**/
	public function invalidate() {
		#if ecx_debug
		makeFamiliesMutable();
		#end

		if(_removedVector.length > 0 || _changedVector.length > 0) {
			destroyEntities();
			changeEntities();
			updateFamilyVectors();
		}

		#if ecx_debug
		guardFamilies();
		makeFamiliesImmutable();
		#end
	}

	/**
		Make `entity` active
	**/
	public function activate(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		if(_activeMask.get(entity.id)) throw 'This entity is already active';
		#end
		_activeMask.enable(entity.id);
		markEntityAsChanged(entity);
	}

	/**
		Make `entity` passive
	**/
	public function deactivate(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		if(!_activeMask.get(entity.id)) throw "This entity is already inactive";
		#end
		_activeMask.disable(entity.id);
		markEntityAsChanged(entity);
	}

	/**
		Convert integer `id` to abstract `Entity` handle.
	**/
	inline public function getEntity(id:Int):Entity {
		return @:privateAccess new Entity(id);
	}

	/**
		Check if `entity` is active
	**/
	inline public function isActive(entity:Entity):Bool {
		return _activeMask.get(entity.id);
	}

	/**
		Check if `entity` is alive
	**/
	inline public function checkAlive(entity:Entity):Bool {
		return _aliveMask.get(entity.id);
	}

	public function toString():String {
		return 'World #$id';
	}

	/**
		Destroy all components attached to `entity`
	**/
	public function destroyComponents(entity:Entity) {
		var componentsData = _components;
		for(typeId in 0...componentsData.length) {
			var component = componentsData[typeId];
			if(component.has(entity)) {
				componentsData[typeId].destroy(entity);
			}
		}
		if(isActive(entity)) {
			markEntityAsChanged(entity);
		}
	}

	/**
		Mark entity as changed
	**/
	inline public function commit(entity:Entity) {
		if(isActive(entity)) {
			markEntityAsChanged(entity);
		}
	}

	/** Iterator for *active* systems ordered by priority **/
	inline public function systems():CArrayIterator<System> {
		return new CArrayIterator<System>(_systems);
	}

	/**
		Iterator for components table
		Component could be null (should be fixed later)
	**/
	inline public function components():CArrayIterator<IComponent> {
		return new CArrayIterator<IComponent>(_components);
	}

	/**
		Theoretic memory consuming in bytes
	**/
	public function getObjectSize():Int {
		var total = _services.getObjectSize();
		total += _orderedServices.getObjectSize();
		total += _systems.getObjectSize();
		total += _processors.getObjectSize();
		total += _families.getObjectSize();
		total += _changedVector.getObjectSize();
		total += _removedVector.getObjectSize();
		total += _pool.getObjectSize();
		total += _aliveMask.getObjectSize();
		total += _activeMask.getObjectSize();
		total += _changedMask.getObjectSize();
		total += _removedMask.getObjectSize();

		for(i in 0..._components.length) {
			var component = _components.get(i);
			if(component != null) {
				total += component.getObjectSize();
			}
		}

		return total;
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
	function destroyEntities() {
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

				destroyComponents(entity);
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
		var familiesTotal = families.length;
		var i = 0;
		while(i < entities.length) {
			var tail = entities.length;
			while (i < tail) {
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
		}
		entities.reset();
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

	function markEntityAsChanged(entity:Entity) {
		#if ecx_debug
		guardEntity(entity);
		#end
		if(_changedMask.enableIfNot(entity.id)) {
			_changedVector.place(entity);
		}
	}
}
