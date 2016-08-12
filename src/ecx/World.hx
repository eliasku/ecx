package ecx;

import ecx.managers.WorldConstructor;
import ecx.types.FamilyData;
import ecx.types.EntityData;
import ecx.types.ComponentType;
import ecx.ds.CArray;
import ecx.ds.Cast;
import ecx.ds.CBitArray;
import ecx.managers.EntityManager;
import ecx.macro.ClassMacroTools;
import haxe.macro.Expr.ExprOf;

#if debug
using ecx.managers.WorldDebug;
#end

@:final
@:keep
@:unreflective
@:access(ecx.System, ecx.EntityView, ecx.Component, ecx.WorldConfig)
class World {

	// Mapping: (type, entity) => component
	public var components(default, null):CArray<CArray<Component>>;

	// Identifier of this world
	public var id(default, null):Int;

	// Maximum amount of entities
	public var capacity(default, null):Int;

	// global ref
	public var engine(default, null):Engine;
	public var entityManager(default, null):EntityManager;

	var _systems:Array<System> = [];
	var _priorities:Array<Int> = [];
	var _lookup:Array<System> = [];
	var _processors:Array<System> = [];
	var _families:CArray<FamilyData>;

	// alive entities
	//var _entities:Array<Entity> = [];
	var _changeList:Array<Entity> = [];
	var _removeList:Array<Entity> = [];

	// entity => entity wrapper
	var _mapToData:CArray<EntityData>;

	// Flags
	var _aliveMask:CBitArray;
	var _activeFlags:CBitArray;
	var _changedFlags:CBitArray;
	var _removedFlags:CBitArray;

	function new(id:Int, engine:Engine, config:WorldConfig, capacity:Int = 0x40000) {
		this.id = id;
		this.engine = engine;
		this.capacity = capacity;
		WorldConstructor.construct(this, config);
	}

	macro public function get<T:System>(self:ExprOf<World>, systemClass:ExprOf<Class<T>>):ExprOf<T> {
		var systemType = ClassMacroTools.systemType(systemClass);
		return macro ecx.ds.Cast.unsafe(@:privateAccess $self._lookup[$systemType.id], $systemClass);
	}

	public function create():Entity {
		var entity = entityManager.alloc();
		_aliveMask.enable(entity.id);
		_activeFlags.enable(entity.id);
		return entity;
	}

	/** Useful for prefabs **/
	public function createPassive():Entity {
		var entity = entityManager.alloc();
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

		entityManager.deleteFromWorld(this, _removeList);

		var changedFlags = _changedFlags;
		var changeList = _changeList;
		var activeFlags = _activeFlags;
		var families = _families;
		var startLength = changeList.length;
		if(changeList.length > 0) {
			var i = 0;
			var end = changeList.length;
			while (i < end) {
				var entity = changeList[i];
				var active = activeFlags.get(entity.id);
				for(j in 0...families.length) {
					@:privateAccess families.get(j)._internal_entityChanged(entity, active);
				}
				changedFlags.disable(entity.id);
				++i;
			}
			#if debug
			if(startLength != changeList.length) throw "update while updating";
			#end
			changeList.splice(0, end);
		}

		#if debug
		guardFamilies();
		unlockFamilies();
		#end
	}

	public function placeInternal(entity:Entity) {
		#if debug
		guardEntity(entity);
		if(_activeFlags.get(entity.id)) throw 'This entity is already active';
		#end
		_activeFlags.enable(entity.id);
		// TODO:
//		for(processor in _processors) {
//			processor._internal_entityChanged(entity, true);
//		}
	}

	public function unplaceInternal(entity:Entity) {
		#if debug
		guardEntity(entity);
		if(!_activeFlags.get(entity.id)) throw "This entity is already inactive";
		#end
		_activeFlags.disable(entity.id);
		// TODO:
//		for(processor in _processors) {
//			processor._internal_entityChanged(entity, false);
//		}
	}

	inline public function edit(entity:Entity):EntityView {
		return new EntityView(_mapToData[entity.id]);
	}

	macro public function mapTo<T:Component>(self:ExprOf<World>, componentClass:ExprOf<Class<T>>):ExprOf<MapTo<T>> {
		return macro new MapTo(cast $self.components[$componentClass.__TYPE.id]);
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

	function _internal_entityChanged(entity:Entity) {
		#if debug
		guardEntity(entity);
		#end
		if(_changedFlags.enableIfNot(entity.id)) {
			_changeList.push(entity);
		}
	}

	@:nonVirtual @:unreflective
	public function addComponent<T:Component>(entity:Entity, component:T, type:ComponentType):T {
		// workaround for old hxcpp
		var comp:Component = component;
		components[type.id][entity.id] = comp;
		var active = isActive(entity);
		#if debug
		comp.checkComponentBeforeLink(entity, this);
		#end
		comp.entity = entity;
		comp.world = this;
		if(active) {
			comp.onAdded();
			_internal_entityChanged(entity);
		}
		return component;
	}

	@:nonVirtual @:unreflective @:extern
	inline public function getComponent<T:Component>(entity:Entity, type:ComponentType, componentClass:Class<T>):T {
		return Cast.unsafe(components[type.id][entity.id], componentClass);
	}

	@:nonVirtual @:unreflective
	inline public function hasComponent(entity:Entity, type:ComponentType):Bool {
		return components[type.id][entity.id] != null;
	}

	@:nonVirtual @:unreflective
	public function removeComponent(entity:Entity, type:ComponentType) {
		var entityToComponent = components[type.id];
		var component:Component = entityToComponent[entity.id];
		if(component != null) {
			#if debug
			component.checkComponentBeforeUnlink();
			#end
			var active = isActive(entity);
			if(active) {
				component.onRemoved();
				_internal_entityChanged(entity);
			}
			component.entity = Entity.INVALID;
			component.world = null;
			entityToComponent[entity.id] = null;
		}
	}

	@:nonVirtual @:unreflective
	public function clearComponents(entity:Entity) {
		var componentsData = components;
		var active = isActive(entity);
		for(typeId in 0...componentsData.length) {
			var component:Component = componentsData[typeId][entity.id];
			if(component != null) {
				#if debug
				component.checkComponentBeforeUnlink();
				#end

				if(active) {
					component.onRemoved();
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
}