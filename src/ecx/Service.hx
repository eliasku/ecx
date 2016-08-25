package ecx;

import ecx.types.ServiceSpec;
import ecx.types.ServiceType;

/**
	Service is injectable world type
**/

#if !macro
@:autoBuild(ecx.macro.ServiceBuilder.build())
#end
@:base
class Service {

	var world(default, null):World;

	function initialize() {}

	@:extern inline static var __TYPE:ServiceType = ServiceType.INVALID;
	@:extern inline static var __SPEC:ServiceSpec = ServiceSpec.INVALID;

	function __serviceType():ServiceType {
		return ServiceType.INVALID;
	}

	function __serviceSpec():ServiceSpec {
		return ServiceSpec.INVALID;
	}

	function __allocate() {}
	function __inject() {}
}
