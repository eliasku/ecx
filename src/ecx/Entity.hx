package ecx;

import ecx.types.ComponentType;
import ecx.types.ComponentType;
import ecx.ds.Cast;
import ecx.macro.ManagerMacro;
import haxe.macro.Expr.ExprOf;

@:final
@:keep
@:unreflective
@:access(ecx.Component)
@:access(ecx.World)
class Entity {

	public var id(default, null):Int;
	public var engine(default, null):Engine;
	public var world(get, never):World;

	inline function new(id:Int, engine:Engine) {
		this.id = id;
		this.engine = engine;
	}

	@:extern inline function __getComponentByType<T:Component>(componentType:ComponentType, componentClass:Class<T>):T {
		return engine.getComponent(id, componentType, componentClass);
	}

	macro public function get<T:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ManagerMacro.componentType(componentClass);
		return macro @:privateAccess $self.__getComponentByType($componentType, $componentClass);
	}

	@:deprecated("very unsafe macro")
	macro public function tryGet<T:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ManagerMacro.componentType(componentClass);
		return macro {
			var tmp:ecx.Entity = $self;
			tmp != null ? @:privateAccess tmp.__getComponentByType($componentType, $componentClass) : null;
		}
	}

	macro public function create<T:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ManagerMacro.componentType(componentClass);
		var instance = ManagerMacro.alloc(componentClass);
		return macro @:privateAccess $self._add($componentType, $instance);
	}

	macro public function has<T:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<T>>):ExprOf<Bool> {
		var componentType = ManagerMacro.componentType(componentClass);

		// TODO: macro duplicates
		return macro @:privateAccess $self.engine.components[$componentType.id][$self.id] != null;
	}

	macro public function remove<T:Component>(self:ExprOf<Entity>, componentClass:ExprOf<Class<T>>) {
		var componentType = ManagerMacro.componentType(componentClass);
		return macro @:privateAccess $self._remove($componentType);
	}

	inline public function addInstance(component:Component) {
		_add(component.__getType(), component);
	}

	@:nonVirtual @:unreflective
	function _add<T:Component>(componentType:ComponentType, component:T):T {
		// workaround for old hxcpp
		var comp:Component = component;
		engine.components[componentType.id][id] = comp;
		comp._internal_setEntity(this);

		var locWorld:World = world;
		if(locWorld != null) {
			locWorld._internal_entityChanged(id);
		}

		return component;
	}

	@:nonVirtual @:unreflective
	function _remove(componentType:ComponentType) {
		var components = engine.components[componentType.id];
		var component:Component = components[id];
		if(component != null) {
			component._internal_setEntity(null);

			var locWorld:World = world;
			if(locWorld != null) {
				locWorld._internal_entityChanged(id);
			}

			components[id] = null;
		}
	}

	@:nonVirtual @:unreflective
	function _clear() {
		var componentsByType = engine.components;
		var id:Int = this.id;
		for(componentTypeId in 0...componentsByType.length) {
			var component:Component = componentsByType[componentTypeId][id];
			if(component != null) {
				component._internal_setEntity(null);
				componentsByType[componentTypeId][id] = null;
			}
		}
	}

	public function deleteFromWorld() {
		world.delete(id);
	}

	inline function get_world():World {
		return engine.worlds[id];
	}

	inline function toString():String {
		return 'entity #$id';
	}
}
