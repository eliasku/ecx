package ;

import utest.TestResult;
import ecx.TestCase;
import utest.Runner;
import utest.ui.Report;

class TestAll {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new TestCase());
		run(runner);
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
		for(l in result.assertations) {
			switch (l){
				case Success(_):
				default: return false;
			}
		}
		return true;
	}
}