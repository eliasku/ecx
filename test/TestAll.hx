package ;

import ecx.EntityVectorTest;
import ecx.ComponentTest;
import ecx.EntityTest;
import ecx.FamilyTest;
import ecx.IssuesTest;
import ecx.MapToTest;
import ecx.ServiceHierarchyTest;
import ecx.WorldTest;
import utest.Runner;
import utest.TestResult;
import utest.ui.Report;

class TestAll {

	public static function main() {
		var runner = new Runner();
		addTests(runner);
		run(runner);
	}

	static function addTests(runner:Runner) {
		runner.addCase(new WorldTest());
		runner.addCase(new EntityTest());
		runner.addCase(new ComponentTest());
		runner.addCase(new MapToTest());
		runner.addCase(new IssuesTest());
		runner.addCase(new ServiceHierarchyTest());
		runner.addCase(new FamilyTest());
		runner.addCase(new EntityVectorTest());
	}

	static function run(runner:Runner) {
		Report.create(runner);

		// get test result to determine exit status
		var isOk:Bool = true;
		runner.onProgress.add(function(o) {
			isOk = isAllOk(o.result) && isOk;
		});
		runner.onComplete.add(function(r) {
			var exitCode = isOk ? 0 : -1;

			#if flash
			flash.system.System.exit(exitCode);
			#end

			#if js
			trace("<hxmake::exit>" + exitCode);
			#end
		});

		runner.run();
	}

	static function isAllOk(result:TestResult):Bool {
		for (l in result.assertations) {
			switch (l){
				case Success(_):
				default: return false;
			}
		}
		return true;
	}
}