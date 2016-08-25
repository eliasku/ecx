package ecx;

@:unreflective
class WorldConfig {

	var _services:Array<Service> = [];
	var _priorities:Array<Int> = [];
	var _configs:Array<WorldConfig> = [];

	public function new(dependencies:Array<WorldConfig> = null) {
		if(dependencies != null) {
			for(dependency in dependencies) {
				require(dependency);
			}
		}
	}

	inline public function add(service:Service, priority:Int = 0) {
		#if ecx_debug
		if(service == null) throw "Null service";
		if(_services.indexOf(service) >= 0) throw "Service already added";
		#end

		_services.push(service);
		_priorities.push(priority);
	}

	public function require(config:WorldConfig) {
		#if ecx_debug
		checkAddedConfigs(config);
		#end

		_configs.push(config);

		var services = config._services;
		var priorities = config._priorities;
		var count = services.length;
		for(i in 0...count) {
			add(services[i], priorities[i]);
		}
	}

	#if ecx_debug
	function checkAddedConfigs(config:WorldConfig) {
		if(config == null) throw "null config";
		if(config == this) throw "can't add self";
		for(c in _configs) {
			c.checkAddedConfigs(config);
		}
	}
	#end
}
