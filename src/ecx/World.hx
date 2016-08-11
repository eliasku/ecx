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
@:access(ecx.System, ecx.EntityView, ecx.Component, ecx.WorldConfig)
class World {

	public var id(default, null):Int;
	public var capacity(default, null):Int;

	// (type, entity) => component
	public var components(default, null):CArray<CArray<Component>>;

	// entity => entity view
	var _mapToEntityView(default, null):CArray<EntityView>;

	// global ref
	public var engine(default, null):Engine;
	public var entityManager(default, null):EntityManager;

	var _systems:Array<System> = [];
	var _priorities:Array<Int> = [];
	var _lookup:Array<System> = [];
	var _processors:Array<System> = [];

	var _entities:Array<Int> = [];
	var _changeList:Array<Int> = [];
	var _removeList:Array<Int> = [];

	var _activeFlags:CBitArray;
	var _changedFlags:CBitArray;
	var _removedFlags:CBitArray;

	public var entitiesTotal(get, never):Int;

	inline function get_entitiesTotal():Int {
		return _entities.length;
	}

	function new(id:Int, engine:Engine, config:WorldConfig, capacity:Int = 0x40000) {
		this.id = id;
		this.engine = engine;
		this.capacity = capacity;

		// init component storage
		components = new CArray(@:privateAccess engine._types.componentsNextTypeId);
		for(i in 0...components.length) {
			components[i] = new CArray(capacity);
		}

		// init entities
		entityManager = new EntityManager(this, capacity);
		_mapToEntityView = entityManager.entities;
		_activeFlags = entityManager.activeFlags;
		_changedFlags = entityManager.changedFlags;
		_removedFlags = entityManager.removedFlags;

		// init systems
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

	inline public function createEntity(activated:Bool = true):EntityView {
		return _mapToEntityView[create(activated)];
	}

	// Recommended
	public function create(activated:Bool = true):Int {
		var entity = entityManager.alloc();
		if(activated) {
			_activeFlags.enable(entity);
		}
		_entities.push(entity);
		return entity;
	}

	public function cloneEntity(source:EntityView):EntityView {
		return _mapToEntityView[clone(source.id)];
	}

	public function clone(source:Int):Int {
		var entity = create();
		// TODO: if we move _add to entity-manager, so we could not use wrapper?
		var entityEdit:EntityView = _mapToEntityView[entity];
		var componentsByType = components;
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
	inline public function deleteEntity(instance:EntityView) {
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

		entityManager.deleteFromWorld(this, _removeList, _entities);

		var updateFlags = _changedFlags;
		var updateList = _changeList;
		var startLength = updateList.length;
		if(updateList.length > 0) {
			var i = 0;
			var end = updateList.length;
			while (i < end) {
				var eid = updateList[i];
				var active = _activeFlags.get(eid);
				for(processor in _processors) {
					processor._internal_entityChanged(eid, active);
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
					if(entity < 0) throw 'FAMILY GUARD: Invalid entity id: $entity';
					if(isDead(entity)) throw 'FAMILY GUARD: $entity is dead, but in family';
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
				// nothing to process
				continue;
			}
			for(family in system._families) {
				family.debugUnlock();
			}
		}
	}
	#end

	inline public function isDead(entity:Int):Bool {
		// TODO: bitarray
		return _entities.indexOf(entity) < 0;
	}

	public function placeInternal(entity:EntityView) {
		#if debug
		if(entity == null) throw 'null entity wrapper';
		if(_activeFlags.get(entity.id)) throw 'This entity is already active';
		if(isDead(entity.id)) throw 'dead Entity';
		#end
		var entityId:Int = entity.id;
		_activeFlags.enable(entityId);
		_entities.push(entityId);
	}

	public function unplaceInternal(entity:EntityView) {
		#if debug
		if(entity == null) throw 'null entity wrapper';
		if(!_activeFlags.get(entity.id)) throw "This entity is alread deactivated";
		if(isDead(entity.id)) throw 'dead Entity';
		#end
		var entityId:Int = entity.id;
		_activeFlags.disable(entityId);
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
	function guardEntity(entity:Int) {
		if(_mapToEntityView[entity] == null) throw "Null entity";
		if(isDead(entity)) throw "Dead entity";
	}
	#end

	public function toString():String {
		return 'World #$id';
	}

	// all alive entities
	inline public function getAllEntities() {
		return _entities;
	}

	inline public function edit(entity:Int):EntityView {
		return _mapToEntityView[entity];
	}

	@:extern
	inline public function getComponentFast<T:Component>(entity:Int, componentType:ComponentType, cls:Class<T>):T {
		return Cast.unsafe_T(components[componentType.id][entity]);
	}

	macro public function mapTo<T:Component>(self:ExprOf<World>, componentClass:ExprOf<Class<T>>):ExprOf<MapTo<T>> {
		return macro new MapTo(cast $self.components[$componentClass.__TYPE.id]);
	}

	inline public function isActive(entity:Int) {
		return _activeFlags.get(entity);
	}
}