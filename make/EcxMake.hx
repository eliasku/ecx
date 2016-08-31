import hxmake.test.TestTask;
import hxmake.haxelib.HaxelibExt;
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

		library(function(ext:HaxelibExt) {
			ext.config.version = "0.1.0";
			ext.config.description = "ECX entity-component-system framework";
			ext.config.url = "https://github.com/eliasku/ecx";
			ext.config.tags = ["entity", "component", "system", "ecs", "ces", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "API 2.0";

			ext.pack.includes = ["src", "haxelib.json", "README.md"];
		});

		var tt = new TestTask();
		tt.debug = true;
		tt.targets = ["neko", "swf", "node", "js", "cpp", "java", "cs"];
		tt.libraries = ["ecx"];
		task("test", tt);
	}
}