package ecx;

import ecx.types.ComponentsArrayData;
import ecx.types.ComponentTableData;
import ecx.ds.CArrayIterator;
import ecx.ds.CInt32RingBuffer;
import ecx.managers.WorldConstructor;
import ecx.types.FamilyData;
import ecx.types.EntityData;
import ecx.types.ComponentType;
import ecx.ds.CArray;
import ecx.ds.Cast;
import ecx.ds.CBitArray;
import ecx.macro.ClassMacroTools;
import haxe.macro.Expr.ExprOf;

#if debug
using ecx.managers.WorldDebug;
#end

@:final @:dce @:unreflective
@:access(ecx.System, ecx.EntityView, ecx.Component, ecx.Family, ecx.Entity)
class World {

	// Mapping: (type, entity) => component
	public var components(default, null):ComponentTableData;

	// Identifier of this world
	public var id(default, null):Int;

	// Maximum amount of entities
	public var capacity(default, null):Int;
	public var used(default, null):Int = 0;
	public var available(get, never):Int;

	// global ref
	public var engine(default, null):Engine;

	// lookup for all systems
	var _lookup:CArray<System>;
	// all systems sorted by priority
	var _orderedSystems:CArray<System>;
	// only active systems (not idle)
	var _systems:CArray<System>;
	// systems with families
	var _processors:CArray<System>;

	var _families:CArray<FamilyData>;

	var _changeList:Array<Entity> = [];
	var _removeList:Array<Entity> = [];

	var _pool:CInt32RingBuffer;

	// entity => entity wrapper
	var _mapToData:CArray<EntityData>;

	// Flags
	var _aliveMask:CBitArray;
	var _activeFlags:CBitArray;
	var _changedFlags:CBitArray;
	var _removedFlags:CBitArray;

	function new(id:Int, engine:Engine, config:WorldConfig, capacity:Int) {
		this.id = id;
		this.engine = engine;
		WorldConstructor.construct(this, capacity, config);
	}

	macro public function resolve<T:System>(self:ExprOf<World>, systemClass:ExprOf<Class<T>>):ExprOf<T> {
		var systemType = ClassMacroTools.systemType(systemClass);
		return macro {
			var tmp = @:privateAccess $self._lookup[$systemType.id];
			ecx.ds.Cast.unsafe(tmp, $systemClass);
		}
	}

	public function create():Entity {
		var entity = allocNextEntity();
		_aliveMask.enable(entity.id);
		_activeFlags.enable(entity.id);
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
			var component:Component = componentsByType[typeId][source.id];
			if(component != null) {
				var cloned = component._newInstance();
				addComponent(entity, cloned, new ComponentType(typeId));

				// TODO: check if we could do copy before adding
				cloned.copyFrom(component);
			}
		}
		return entity;
	}

	public function delete(entity:Entity) {
		#if debug
		guardEntity(entity);
		#end
		if(_removedFlags.enableIfNot(entity.id)) {
			_removeList.push(entity);
		}
	}

	public function invalidate() {
		#if debug
		lockFamilies();
		#end

		if(_removeList.length > 0 || _changeList.length > 0) {
			deleteEntities(_removeList);
			changeEntities(_changeList);
			for(family in _families) {
				var entities = family.entities;
				if(entities.changed) {
					entities.invalidate();
				}
			}
		}

		#if debug
		guardFamilies();
		unlockFamilies();
		#end
	}

	public function activate(entity:Entity) {
		#if debug
		guardEntity(entity);
		if(_activeFlags.get(entity.id)) throw 'This entity is already active';
		#end
		_activeFlags.enable(entity.id);
		_internal_entityChanged(entity);
	}

	public function deactivate(entity:Entity) {
		#if debug
		guardEntity(entity);
		if(!_activeFlags.get(entity.id)) throw "This entity is already inactive";
		#end
		_activeFlags.disable(entity.id);
		_internal_entityChanged(entity);
	}

	inline public function edit(entity:Entity):EntityView {
		return new EntityView(_mapToData[entity.id]);
	}

	macro public function mapTo<T:Component>(self:ExprOf<World>, componentClass:ExprOf<Class<T>>):ExprOf<MapTo<T>> {
		return macro new ecx.MapTo($componentClass, cast $self.components[$componentClass.__TYPE.id]);
	}

	inline public function isActive(entity:Entity):Bool {
		return _activeFlags.get(entity.id);
	}

	inline public function checkAlive(entity:Entity):Bool {
		return _aliveMask.get(entity.id);
	}

	public function toString():String {
		return 'World #$id';
	}

	@:nonVirtual @:unreflective
	public function addComponent<T:Component>(entity:Entity, component:T, type:ComponentType):T {
		// workaround for haxe < 3.3: cpp generation (avoid dynamic_cast<>)
		var comp:Component = component;
		components[type.id][entity.id] = comp;
		var active = isActive(entity);
		#if debug
		comp.checkComponentBeforeLink(entity, this);
		#end
		comp.entity = entity;
		comp.world = this;
		comp.onAdded();
		if(active) {
			_internal_entityChanged(entity);
		}
		return component;
	}

	@:nonVirtual @:unreflective @:extern
	inline public function getComponent<T:Component>(entity:Entity, type:ComponentType, componentClass:Class<T>):T {
		return Cast.unsafe(components[type.id][entity.id], componentClass);
	}

	inline public function hasComponent(entity:Entity, type:ComponentType):Bool {
		return components[type.id][entity.id] != null;
	}

	public function removeComponent(entity:Entity, type:ComponentType) {
		var entityToComponent:ComponentsArrayData = components[type.id];
		var component:Component = entityToComponent[entity.id];

		if(component != null) {
			#if debug
			component.checkComponentBeforeUnlink();
			#end
			var active = isActive(entity);
			component.onRemoved();
			if(active) {
				_internal_entityChanged(entity);
			}
			component.entity = Entity.INVALID;
			component.world = null;
			entityToComponent[entity.id] = null;
		}
	}

	public function clearComponents(entity:Entity) {
		var componentsData = components;
		var active = isActive(entity);
		for(typeId in 0...componentsData.length) {
			var component:Component = componentsData[typeId][entity.id];
			if(component != null) {
				#if debug
				component.checkComponentBeforeUnlink();
				#end

				component.onRemoved();
				if(active) {
				}
				component.entity = Entity.INVALID;
				component.world = null;

				componentsData[typeId][entity.id] = null;
			}
		}

		if(active) {
			_internal_entityChanged(entity);
		}
	}

	/** Iterator for *active* systems ordered by priority **/
	inline public function systems():CArrayIterator<System> {
		return new CArrayIterator<System>(_systems);
	}

	function allocNextEntity():Entity {
		#if debug
		if(used >= capacity) throw 'Out of entities, max allowed $capacity';
		#end

		++used;
		return new Entity(_pool.pop());
	}

	inline function get_available():Int {
		return capacity - used;
	}

	function deleteEntities(entities:Array<Entity>) {
		var locPool:CInt32RingBuffer = _pool;
		var locRemovedFlags = _removedFlags;
		var locActiveFlags = _activeFlags;
		var locAliveMask = _aliveMask;
		var families = _families;
		var i = 0;
		while(i < entities.length) {
			var tail = entities.length;
			while(i < tail) {
				var entity = entities[i];

				// Need to remove entities from families before deletion and notify systems
				for(j in 0...families.length) {
					@:privateAccess families.get(j)._internal_entityChanged(entity, false);
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
		if(count > 0) {
			used -= count;
			#if debug
			if(used < 0) throw "No way!";
			#end
			//if(startLength != removeList.length) throw "removing while removing";
			entities.splice(0, count);
		}
	}

	function changeEntities(entities:Array<Entity>) {
		var changedFlags = _changedFlags;
		var activeFlags = _activeFlags;
		var aliveMask = _aliveMask;
		var families = _families;
		var startLength = entities.length;
		if(entities.length > 0) {
			var i = 0;
			var end = entities.length;
			while (i < end) {
				var entity = entities[i];
				var alive = aliveMask.get(entity.id);
				if(alive) {
					var active = activeFlags.get(entity.id);
					for(j in 0...families.length) {
						@:privateAccess families.get(j)._internal_entityChanged(entity, active);
					}
				}
				changedFlags.disable(entity.id);
				++i;
			}
			#if debug
			if(startLength != entities.length) throw "update while updating";
			#end
			entities.splice(0, end);
		}
	}

	function _internal_entityChanged(entity:Entity) {
		#if debug
		guardEntity(entity);
		#end
		if(_changedFlags.enableIfNot(entity.id)) {
			_changeList.push(entity);
		}
	}
}
