package ecx;

import utest.Runner;
import utest.ui.Report;

class TestAll {
	public static function main() {
		var runner = new Runner();
		runner.addCase(new TestCase());
		Report.create(runner);
		runner.run();
	}
}