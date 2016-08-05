package ecx;

import ecx.ds.Cast;
import ecx.ds.CBitArray;
import ecx.ds.CArray;
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
	var _toUpdate:Array<Int> = [];
	var _toRemove:Array<Int> = [];

	// global ref
	public var engine(default, null):Engine;
	var _edb:EntityManager;
	var _updateFlags:CBitArray;
	var _removeFlags:CBitArray;

	public var entitiesTotal(get, never):Int;

	inline function get_entitiesTotal():Int {
		return _entities.length;
	}

	function new(id:Int, engine:Engine, config:WorldConfig) {
		this.id = id;
		this.engine = engine;
		_edb = engine.entityManager;
		_updateFlags = _edb.updateFlags;
		_removeFlags = _edb.removeFlags;
		var systems = config._systems;
		var priorities = config._priorities;
		var total = systems.length;
		for(i in 0...total) {
			register(systems[i], priorities[i]);
		}
		initialize();
	}

	macro public function get<T:System>(self:ExprOf<World>, cls:ExprOf<Class<T>>):ExprOf<T> {
		var id = ManagerMacro.id(cls);
		//return macro @:privateAccess $self._lookup[$id]._cast($cls);
		return macro ecx.ds.Cast.unsafe(@:privateAccess $self._lookup[$id], $cls);
	}

	public function create():Entity {
		var eid = _edb.alloc();
		var entity:Entity = _edb.map[eid];
		_edb.worlds[eid] = this;
		_entities.push(eid);
		return entity;
	}

	public function clone(source:Entity):Entity {
		var entity = create();
		var componentsByType = engine.components;
		var sourceId = source.id;
		for(cid in 0...componentsByType.length) {
			var component:Component = componentsByType[cid][sourceId];
			//trace("ID: " + id + " CID: " + cid + " | " + component);
			if(component != null) {
				var cloned = component._newInstance();
				//trace(cloned);
				entity._add(cid, cloned);
				//trace(cid + " : " + componentsByType[cid][id]);
				cloned.copyFrom(component);
			}
		}
		return entity;
	}

	public function delete(entity:Entity) {
		var id:Int = entity.id;
		#if debug
		guardEntity(id);
		#end
		if(_removeFlags.enableIfNot(id)) {
			_toRemove.push(id);
		}
	}

	public function invalidate() {
		_edb.freeFromWorld(this, _toRemove, _entities);

		var updateFlags = _updateFlags;
		var updateList = _toUpdate;
		var startLength = updateList.length;
		if(updateList.length > 0) {
			var i = 0;
			var end = updateList.length;
			while (i < end) {
				var eid = updateList[i];
				for(processor in _processors) {
					processor._internal_entityChanged(eid);
				}
				updateFlags.disable(eid);
				++i;
			}
			if(startLength != updateList.length) throw "update while updating";
			updateList.splice(0, end);
		}
	}

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
		var eid:Int = entity.id;
		engine.worlds[eid] = null;
		for(processor in _processors) {
			processor._internal_entityChanged(eid);
		}
		_entities.remove(eid);
	}

	function register(system:System, priority:Int) {
		_lookup[system._typeId()] = system;
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
			if((_systems[i]._flags & System.Flags.CONFIG) != 0) {
				_systems.splice(i, 1);
			}
			--i;
		}
	}

	function _internal_entityChanged(id:Int) {
		#if debug
		guardEntity(id);
		#end
		if(_updateFlags.enableIfNot(id)) {
			_toUpdate.push(id);
		}
	}

	#if debug
	function guardEntity(id:Int) {
		if(engine.mapToEntity[id] == null) throw "Null entity";
		if(engine.worlds[id] != this) throw "Entity from another world";
	}
	#end

	public function toString():String {
		return "World";
	}

	inline public function getAllEntities() {
		return _entities;
	}
}