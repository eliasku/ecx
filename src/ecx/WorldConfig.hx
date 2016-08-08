package ecx;

@:unreflective
class WorldConfig {

	var _systems:Array<System> = [];
	var _priorities:Array<Int> = [];
	var _configs:Array<WorldConfig> = [];

	public function new(dependencies:Array<WorldConfig> = null) {
		if(dependencies != null) {
			for(dependency in dependencies) {
				require(dependency);
			}
		}
	}

	inline public function add(system:System, priority:Int = 0) {
		#if debug
		if(system == null) throw "Null system";
		if(_systems.indexOf(system) >= 0) throw "System already added";
		#end

		_systems.push(system);
		_priorities.push(priority);
	}

	public function require(config:WorldConfig) {
		#if debug
		if(config == null) throw "null config";
		checkAddedConfigs(config);
		#end

		_configs.push(config);

		var systems = config._systems;
		var priorities = config._priorities;
		var count = systems.length;
		for(i in 0...count) {
			add(systems[i], priorities[i]);
		}
	}

	#if debug
	function checkAddedConfigs(config:WorldConfig) {
		if(config == this) throw "can't add self";
		for(c in _configs) {
			c.checkAddedConfigs(config);
		}
	}
	#end
}
