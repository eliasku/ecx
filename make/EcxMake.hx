import hxmake.idea.IdeaPlugin;
import hxmake.haxelib.HaxelibPlugin;

using hxmake.haxelib.HaxelibPlugin;

class EcxMake extends hxmake.Module {

	function new() {
		config.classPath = ["src"];
		config.testPath = ["test"];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		var cfg = library().config;
		cfg.version = "0.0.1";
		cfg.description = "ECX entity-component-system framework";
		cfg.url = "https://github.com/eliasku/ecx";
		cfg.tags = ["entity", "component", "system", "ecs", "ces", "cross"];
		cfg.contributors = ["eliasku"];
		cfg.license = "MIT";
	}
}