package ecx.managers;

import ecx.ds.CArray;
import ecx.types.FamilyData;
import ecx.types.SystemFlags;

@:access(ecx.World, ecx.System, ecx.Engine, ecx.WorldConfig)
class WorldConstructor {

	@:allow(ecx.World)
	static function construct(world:World, config:WorldConfig) {
		createComponentsData(world);
		createEntityManager(world);
		register(world, config);
		routeSystems(world);
		createFamilyList(world);
		initializeSystems(world);
		deleteConfigurators(world);
	}

	static function createComponentsData(world:World) {
		var capacity = world.capacity;
		var typesCount = world.engine._types.componentsNextTypeId;

		var components:CArray<CArray<Component>> = new CArray(typesCount);
		for(i in 0...components.length) {
			components[i] = new CArray(capacity);
		}

		world.components = components;
	}

	static function createEntityManager(world:World) {
		var entityManager = new EntityManager(world, world.capacity);
		world.entityManager = entityManager;
		world._mapToData = entityManager.mapToData;
		world._aliveMask = entityManager.aliveMask;
		world._activeFlags = entityManager.activeFlags;
		world._changedFlags = entityManager.changedFlags;
		world._removedFlags = entityManager.removedFlags;
	}

	static function register(world:World, config:WorldConfig) {
		var systems = config._systems;
		var priorities = config._priorities;
		var total = systems.length;
		for(i in 0...total) {
			registerSystem(world, systems[i], priorities[i]);
		}
	}

	static function registerSystem(world:World, system:System, priority:Int) {
		world._lookup[system.__getType().id] = system;
		world._systems.push(system);
		world._priorities.push(priority);
	}

	static function routeSystems(world:World) {

		var systems = world._systems;
		var processors = world._processors;
		#if debug
		if(systems.length == 0) throw "Empty world is invalid";
		#end

		for(system in systems) {
			system.world = world;
			system._inject();
			if(system._isProcessor()) {
				processors.push(system);
			}
		}
	}

	static function createFamilyList(world:World) {
		var list:Array<FamilyData> = [];

		for(processor in world._processors) {
			for(family in processor._families) {
				list.push(family);
			}
		}

		var data = new CArray<FamilyData>(list.length);
		for(i in 0...list.length) {
			data[i] = list[i];
		}

		world._families = data;
	}

	static function initializeSystems(world:World) {
		for(system in world._systems) {
			system.initialize();
		}
	}

	static function deleteConfigurators(world:World) {
		var systems = world._systems;

		var i = systems.length - 1;
		while(i >= 0) {
			if(systems[i]._flags.has(SystemFlags.CONFIG)) {
				systems.splice(i, 1);
			}
			--i;
		}
	}
}
