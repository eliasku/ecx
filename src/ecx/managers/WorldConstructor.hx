package ecx.managers;

import ecx.types.EntityVector;
import ecx.types.ComponentTable;
import ecx.ds.CBitArray;
import ecx.types.EntityData;
import ecx.ds.CInt32RingBuffer;
import ecx.ds.CArray;
import ecx.types.FamilyData;

@:dce @:final @:unreflective
@:access(ecx.World, ecx.System, ecx.Engine, ecx.Entity)
@:access(ecx.WorldConfig, ecx.types.EntityData)
@:allow(ecx.World)
class WorldConstructor {

	static function construct(world:World, capacity:Int, config:WorldConfig) {
		#if ecx_debug
		if(config == null) throw "world config required";
		if(capacity <= 1) throw "capacity is so low: " + capacity;
		if(capacity >= 0x3FFFFFFF - 1) throw "too much entities: " + capacity;
		#end

		// capacity alignment
		capacity = nextPowerOfTwo(capacity - 1) + 1;
		world.capacity = capacity;

		// components table
		world._components = createComponentsData(config);

		// entities support
		world._pool = createEntityPool(capacity);
		//world._mapToData = createEntityWrappers(world);
		world._aliveMask = new CBitArray(capacity);
		world._activeMask = new CBitArray(capacity);

		world._changedVector = new EntityVector(capacity - 1);
		world._removedVector = new EntityVector(capacity - 1);
		world._changedMask = new CBitArray(capacity);
		world._removedMask = new CBitArray(capacity);

		// services
		world._services = createServicesLookup(config);
		world._orderedServices = createServicesOrder(config);
		routeServices(world);
		createFamilyList(world);
		initializeServices(world);
		deleteConfigurators(world);
	}

	@:access(ecx.IComponent)
	static function createComponentsData(config:WorldConfig):ComponentTable {
		var components:Array<IComponent> = [];
		var maxTypeId = 0;
		for(service in config._services) {
			if(Std.is(service, IComponent)) {
				var component:IComponent = cast service;
				components.push(component);
				var typeId = component.__componentType().id;
				if(typeId > maxTypeId) {
					maxTypeId = typeId;
				}
			}
		}

		var table = new ComponentTable(maxTypeId + 1);
		for(component in components) {
			table[component.__componentType().id] = component;
		}
		return table;
	}

	static function createEntityPool(capacity:Int):CInt32RingBuffer {
		// capacity is POT; 0 is invalid;
		// generate valid entities: {1, 2, 3, 4} for cap = 5
		var pool = new CInt32RingBuffer(capacity - 1);
		for(i in 0...pool.length) {
			pool.set(i, i + 1);
		}
		return pool;
	}

	// unused
//	static function createEntityWrappers(world:World) {
//		var wrappers = new CArray<EntityData>(world.capacity);
//		for(id in 1...wrappers.length) {
//			wrappers[id] = new EntityData(new Entity(id), world);
//		}
//		return wrappers;
//	}

	@:access(ecx.Service)
	static function createServicesLookup(config:WorldConfig):CArray<Service> {
		var services = new Array<Service>();
		for(system in config._services) {
			services[system.__serviceType().id] = system;
		}
		return CArray.fromArray(services);
	}

	static function createServicesOrder(config:WorldConfig):CArray<Service> {
		var services = config._services;
		var priorities = config._priorities;

		var sortIndices:Array<Int> = [];
		for(i in 0...services.length) {
			sortIndices.push(i);
		}

		sortIndices.sort(function (x, y) {
			return priorities[x] - priorities[y];
		});

		var orderedServices = new CArray<Service>(services.length);
		for(i in 0...services.length) {
			orderedServices[i] = services[sortIndices[i]];
		}
		return orderedServices;
	}

	@:access(ecx.Service)
	static function routeServices(world:World) {
		var processors = [];
		var active = [];

		for(service in world._orderedServices) {
			service.world = world;

			var system:System = Std.instance(service, System);
			if(system != null) {
				system.__configure();
				if(system._families != null && system._families.length > 0) {
					processors.push(system);
				}
				if(!system._isIdle()) {
					active.push(system);
				}
			}

			service.__allocate();
			service.__inject();
		}
		world._systems = CArray.fromArray(active);
		world._processors = CArray.fromArray(processors);
	}

	static function createFamilyList(world:World) {
		var families:Array<FamilyData> = [];

		for(processor in world._processors) {
			for(family in processor._families) {
				families.push(family);
			}
		}

		world._families = CArray.fromArray(families);
	}

	@:access(ecx.Service)
	static function initializeServices(world:World) {
		for(service in world._orderedServices) {
			service.initialize();
		}
	}

	static function deleteConfigurators(world:World) {
		// TODO: somehow
	}

	static function nextPowerOfTwo(value:Int):Int {
		if (value == 0) {
			return 1;
		}
		--value;
		value |= value >> 1;
		value |= value >> 2;
		value |= value >> 4;
		value |= value >> 8;
		value |= value >> 16;
		return value + 1;
	}
}
