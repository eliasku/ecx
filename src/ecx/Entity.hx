package ecx;

import ecx.macro.ManagerMacro;
import haxe.macro.Expr.ExprOf;

@:final
@:keep
@:unreflective
@:access(ecx.Component)
@:access(ecx.World)
class Entity {

	public var id(default, null):Int;
	public var database(default, null):Engine;
	public var world(get, never):World;

	inline function new() {}

	@:extern inline public function getComponent<T:Component>(typeId:Int, cls:Class<T>):T {
		return database.components[typeId][id]._cast(cls);
	}

	macro public function get<T:Component>(self:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T> {
		var idExpr:ExprOf<Int> = ManagerMacro.id(type);
//		return macro @:privateAccess $self.database.components[$idExpr][$self.id]._cast($type);
		return macro $self.getComponent($idExpr, $type);
	}

	@:deprecated("very unsafe macro")
	macro public function tryGet<T:Component>(self:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T> {
		var idExpr:ExprOf<Int> = ManagerMacro.id(type);
		return macro {
			var tmp:ecx.Entity = $self;
			tmp != null ? tmp.getComponent($idExpr, $type) : null;
		}
	}

	macro public function create<T:Component>(self:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<T> {
		var idExpr:ExprOf<Int> = ManagerMacro.id(type);
		var instExpr:ExprOf<T> = ManagerMacro.alloc(type);
		return macro @:privateAccess $self._add($idExpr, $instExpr);
	}

	macro public function has<T:Component>(self:ExprOf<Entity>, type:ExprOf<Class<T>>):ExprOf<Bool> {
		var idExpr:ExprOf<Int> = ManagerMacro.id(type);
		return macro @:privateAccess $self.database.components[$idExpr][$self.id] != null;
	}

	macro public function remove<T:Component>(self:ExprOf<Entity>, type:ExprOf<Class<T>>) {
		var idExpr:ExprOf<Int> = ManagerMacro.id(type);
		return macro @:privateAccess $self._remove($idExpr);
	}

	inline public function addInstance(component:Component) {
		_add(component._typeId(), component);
	}

	@:nonVirtual @:unreflective
	public static function prefab():Entity {
		return Engine.instance.edb.create();
	}

	@:nonVirtual @:unreflective
	function _add<T:Component>(typeId:Int, component:T):T {
		database.components[typeId][id] = component;
		component._internal_setEntity(this);
		if(world != null) {
			world._internal_entityChanged(id);
		}
		return component;
	}

	@:nonVirtual @:unreflective
	function _remove(typeId:Int) {
		var components = database.components[typeId];
		var component:Component = components[id];
		if(component != null) {
			component._internal_setEntity(null);
			if(world != null) {
				world._internal_entityChanged(id);
			}
			components[id] = null;
		}
	}

	@:nonVirtual @:unreflective
	function _clear() {
		var componentsByType = database.components;
		var id:Int = this.id;
		for(typeId in 0...componentsByType.length) {
			var component:Component = componentsByType[typeId][id];
			if(component != null) {
				component._internal_setEntity(null);
				componentsByType[typeId][id] = null;
			}
		}
	}

	inline function get_world():World {
		return database.worlds[id];
	}

}
