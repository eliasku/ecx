package ecx.managers;

#if debug

class WorldDebug {

	@:access(ecx.World)
	public static function guardEntity(world:World, entity:Entity) {
		if(!entity.isValid) throw "Invalid entity";
		if(world._mapToData[entity.id] == null) throw "Null entity";
		if(world._aliveMask.isFalse(entity.id)) throw "Dead entity";
	}

	@:access(ecx.World)
	public static function guardFamilies(world:World) {
		for(i in 0...world._families.length) {
			var family = world._families.get(i);
			for(entity in family.entities) {
				if(!entity.isValid) throw 'FAMILY GUARD: Invalid entity id: ${entity.id}';
				if(world._aliveMask.isFalse(entity.id)) throw 'FAMILY GUARD: ${entity.id} is dead, but in family';
			}
		}
	}

	@:access(ecx.World)
	public static function lockFamilies(world:World) {
		for(i in 0...world._families.length) {
			world._families.get(i).debugLock();
		}
	}

	@:access(ecx.World)
	public static function unlockFamilies(world:World) {
		for(i in 0...world._families.length) {
			world._families.get(i).debugUnlock();
		}
	}

	public static function checkComponentBeforeLink(component:Component, entity:Entity, world:World) {
		if(world == null) throw "bad world for linking";
		if(component.entity.isValid) throw "already linked to entity";
		if(!entity.isValid) throw "bad entity for linking";
	}

	public static function checkComponentBeforeUnlink(component:Component) {
		if(component.world == null) throw "already not linked to entity";
		if(!component.entity.isValid) throw "linked, but has bad entity";
	}
}

#end