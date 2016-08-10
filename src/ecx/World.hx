package ecx;

import ecx.types.SystemFlags;
import ecx.types.ComponentType;
import ecx.ds.CArray;
import ecx.ds.Cast;
import ecx.ds.CBitArray;
import ecx.managers.EntityManager;
import ecx.macro.ManagerMacro;
import haxe.macro.Expr.ExprOf;

/**

- Batch update per family (pass array of updated entities into handler)

**/

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.Entity, ecx.Component, ecx.WorldConfig)
class World {

	public var id(default, null):Int;

	var _systems:Array<System> = [];
	var _priorities:Array<Int> = [];
	var _lookup:Array<System> = []; // Map<Int, System>
	var _processors:Array<System> = [];

	var _entities:Array<Int> = [];
	var _changeList:Array<Int> = [];
	var _removeList:Array<Int> = [];

	// global ref
	public var engine(default, null):Engine;
	var _edb:EntityManager;
	var _mapToEntity:CArray<Entity>;
	var _changedFlags:CBitArray;
	var _removedFlags:CBitArray;

	public var entitiesTotal(get, never):Int;

	inline function get_entitiesTotal():Int {
		return _entities.length;
	}

	function new(id:Int, engine:Engine, config:WorldConfig) {
		this.id = id;
		this.engine = engine;
		_edb = engine.entityManager;
		_changedFlags = _edb.updateFlags;
		_removedFlags = _edb.removeFlags;
		_mapToEntity = _edb.entities;
		var systems = config._systems;
		var priorities = config._priorities;
		var total = systems.length;
		for(i in 0...total) {
			register(systems[i], priorities[i]);
		}
		initialize();
	}

	macro public function get<T:System>(self:ExprOf<World>, systemClass:ExprOf<Class<T>>):ExprOf<T> {
		var systemType = ManagerMacro.systemType(systemClass);
		return macro ecx.ds.Cast.unsafe_T(@:privateAccess $self._lookup[$systemType.id]);
	}

	inline public function createEntity():Entity {
		return _mapToEntity[create()];
	}

	// Recommended
	public function create():Int {
		var entity = _edb.alloc();
		_edb.worlds[entity] = this;
		_entities.push(entity);
		return entity;
	}

	public function cloneEntity(source:Entity):Entity {
		return _mapToEntity[clone(source.id)];
	}

	public function clone(source:Int):Int {
		var entity = create();
		// TODO: if we move _add to entity-manager, so we could not use wrapper?
		var entityEdit:Entity = _mapToEntity[entity];
		var componentsByType = engine.components;
		for(componentTypeId in 0...componentsByType.length) {
			var component:Component = componentsByType[componentTypeId][source];
			if(component != null) {
				var cloned = component._newInstance();
				entityEdit._add(new ComponentType(componentTypeId), cloned);
				cloned.copyFrom(component);
			}
		}
		return entity;
	}

	// TODO: EntityEdit::dispose() ?
	inline public function deleteEntity(instance:Entity) {
		#if debug
		if(instance == null) throw "Null entity wrapper";
		#end
		delete(instance.id);
	}

	// TODO: should be delete
	public function delete(entity:Int) {
		#if debug
		guardEntity(entity);
		#end
		if(_removedFlags.enableIfNot(entity)) {
			_removeList.push(entity);
		}
	}

	public function invalidate() {

		#if debug
		lockFamilies();
		#end

		_edb.freeFromWorld(this, _removeList, _entities);

		var updateFlags = _changedFlags;
		var updateList = _changeList;
		var startLength = updateList.length;
		if(updateList.length > 0) {
			var i = 0;
			var end = updateList.length;
			while (i < end) {
				var eid = updateList[i];
				var worldMatched = _edb.worlds[eid] == this;
				for(processor in _processors) {
					processor._internal_entityChanged(eid, worldMatched);
				}
				updateFlags.disable(eid);
				++i;
			}
			if(startLength != updateList.length) throw "update while updating";
			updateList.splice(0, end);
		}

		#if debug
		guardFamilies();
		unlockFamilies();
		#end
	}

	#if debug
	function guardFamilies() {
		for(system in _systems) {
			if(system._families == null) {
				// not processor
				continue;
			}
			for(family in system._families) {
				for(entity in family.entities) {
					if(entity < 0) throw 'FAMILY GUARD: Bad entity $entity';
					if(_edb.worlds[entity] == null) throw 'FAMILY GUARD: $entity is deleted from world, but in family';
				}
			}
		}
	}

	function lockFamilies() {
		for(system in _systems) {
			if(system._families == null) {
				// not processor
				continue;
			}
			for(family in system._families) {
				family.debugLock();
			}
		}
	}

	function unlockFamilies() {
		for(system in _systems) {
			if(system._families == null) {
				// not processor
				continue;
			}
			for(family in system._families) {
				family.debugUnlock();
			}
		}
	}
	#end

	public function placeInternal(entity:Entity) {
		#if debug
		if(entity.world != null) throw "World is not empty before internal placing";
		#end
		var eid = entity.id;
		engine.worlds[eid] = this;
		_entities.push(eid);
	}

	public function unplaceInternal(entity:Entity) {
		#if debug
		if(entity.world != this) throw "World is BAD before internal unplacing";
		#end
		var entityId:Int = entity.id;
		_edb.worlds[entityId] = null;
		for(processor in _processors) {
			processor._internal_entityChanged(entityId, false);
		}
		_entities.remove(entityId);
	}

	function register(system:System, priority:Int) {
		_lookup[system.__getType().id] = system;
		_systems.push(system);
		_priorities.push(priority);
	}

	function initialize() {
		#if debug
		if(_systems.length == 0) throw "Empty world is invalid";
		#end

		for(system in _systems) {
			system.world = this;
			system.engine = engine;
			system._inject();
			if(system._isProcessor()) {
				_processors.push(system);
			}
		}

		for(system in _systems) {
			system.initialize();
		}

		// clear config systems
		var i = _systems.length - 1;
		while(i >= 0) {
			if(_systems[i]._flags.has(SystemFlags.CONFIG)) {
				_systems.splice(i, 1);
			}
			--i;
		}
	}

	function _internal_entityChanged(id:Int) {
		#if debug
		guardEntity(id);
		#end
		if(_changedFlags.enableIfNot(id)) {
			_changeList.push(id);
		}
	}

	#if debug
	function guardEntity(id:Int) {
		if(engine.mapToEntity[id] == null) throw "Null entity";
		if(engine.worlds[id] != this) throw "Entity from another world";
	}
	#end

	public function toString():String {
		return 'World #$id';
	}

	inline public function getAllEntities() {
		return _entities;
	}
}