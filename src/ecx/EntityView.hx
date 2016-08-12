package ecx;

import ecx.types.EntityData;
import ecx.ds.Cast;
import ecx.types.ComponentType;
import ecx.macro.ClassMacroTools;
import haxe.macro.Expr.ExprOf;

@:final
@:keep
@:unreflective
@:access(ecx.Component)
@:access(ecx.World)
abstract EntityView(EntityData) {

	public var id(get, never):Int;
	public var entity(get, never):Entity;
	public var world(get, never):World;
	public var alive(get, never):Bool;
	public var active(get, never):Bool;

	inline function new(wrapper:EntityData) {
		this = wrapper;
	}

	macro public function get<T:Component>(self:ExprOf<EntityView>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ClassMacroTools.componentType(componentClass);
		return macro @:privateAccess $self.__get($componentType, $componentClass);
	}

	@:deprecated("very unsafe macro")
	macro public function tryGet<T:Component>(self:ExprOf<EntityView>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ClassMacroTools.componentType(componentClass);
		return macro {
			var tmp:ecx.EntityView = $self;
			tmp != null ? @:privateAccess tmp.__get($componentType, $componentClass) : null;
		}
	}

	macro public function create<T:Component>(self:ExprOf<EntityView>, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentType = ClassMacroTools.componentType(componentClass);
		var instance = ClassMacroTools.allocComponent(componentClass);
		return macro @:privateAccess $self.__add($instance, $componentType);
	}

	macro public function has<T:Component>(self:ExprOf<EntityView>, componentClass:ExprOf<Class<T>>):ExprOf<Bool> {
		var componentType = ClassMacroTools.componentType(componentClass);
		return macro @:privateAccess $self.__has($componentType);
	}

	macro public function remove<T:Component>(self:ExprOf<EntityView>, componentClass:ExprOf<Class<T>>) {
		var componentType = ClassMacroTools.componentType(componentClass);
		return macro @:privateAccess $self.__remove($componentType);
	}

	inline public function addInstance(component:Component) {
		world.addComponent(entity, component, component.__getType());
	}

	public function delete() {
		world.delete(entity);
	}

	public function clear() {
		world.clearComponents(entity);
	}

	function toString():String {
		return 'Entity #$id';
	}

	inline function get_id():Int {
		return this.entity.id;
	}

	inline function get_entity():Entity {
		return this.entity;
	}

	inline function get_world():World {
		return this.world;
	}

	inline function get_alive():Bool {
		return world.checkAlive(entity);
	}

	inline function get_active():Bool {
		return world.isActive(entity);
	}

	@:extern inline function __add<T:Component>(component:T, type:ComponentType):T {
		return world.addComponent(entity, component, type);
	}

	@:extern inline function __remove(type:ComponentType) {
		world.removeComponent(entity, type);
	}

	@:extern inline function __has(type:ComponentType):Bool {
		return world.hasComponent(entity, type);
	}

	@:extern inline function __get<T:Component>(componentType:ComponentType, componentClass:Class<T>):T {
		return Cast.unsafe(this.world.components[componentType.id][entity.id], componentClass);
	}
}
