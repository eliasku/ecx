package ecx;

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

	var _systems:Array<System> = [];
	var _priorities:Array<Int> = [];
	var _lookup:Array<System> = []; // Map<Int, System>
	var _processors:Array<System> = [];

	public var database(default, null):Engine;
	public var entitiesTotal(get, never):Int;

	inline function get_entitiesTotal():Int {
		return _entities.length;
	}

	var _edb:EntityManager;
	var _entities:Array<Entity> = [];

	var _toUpdate:Array<Int> = [];
	var _toRemove:Array<Entity> = [];

	function new(database:Engine, config:WorldConfig) {
		this.database = database;
		_edb = database.edb;
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
		return macro @:privateAccess $self._lookup[$id]._cast($cls);
	}

	public function create():Entity {
		var e:Entity = _edb.create();
		database.worlds[e.id] = this;
		_entities.push(e);
		return e;
	}

	public function clone(source:Entity):Entity {
		var entity = create();
		var componentsByType = database.components;
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
		var flags:Array<Int> = database.flags;
		if((flags[id] & 0x2) == 0) {
			_toRemove.push(entity);
			flags[id] |= 0x2;
		}
	}

	public function invalidate() {
		_edb.freeFromWorld(this, _toRemove, _entities);

		var flags:Array<Int> = database.flags;
		var updateList = _toUpdate;
		var startLength = updateList.length;
		if(updateList.length > 0) {
			var i = 0;
			var end = updateList.length;
			while (i < end) {
				var e = updateList[i];
				for(processor in _processors) {
					processor._internal_entityChanged(e);
				}
				flags[e] &= ~0x1;
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
		database.worlds[entity.id] = this;
		_entities.push(entity);
	}

	public function unplaceInternal(entity:Entity) {
		#if debug
		if(entity.world != this) throw "World is BAD before internal unplacing";
		#end
		var id:Int = entity.id;
		database.worlds[id] = null;
		for(processor in _processors) {
			processor._internal_entityChanged(id);
		}
		_entities.remove(entity);
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
		var flags:Array<Int> = database.flags;
		if((flags[id] & 0x1) == 0) {
			flags[id] |= 0x1;
			_toUpdate.push(id);
		}
	}

	#if debug
	function guardEntity(id:Int) {
		if(database.entities[id] == null) throw "Null entity";
		if(database.worlds[id] != this) throw "Entity from another world";
	}
	#end
}
