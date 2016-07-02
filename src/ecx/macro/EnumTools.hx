package ecx.macro;

class EnumTools {
	public static macro function extract(value:haxe.macro.Expr.ExprOf<EnumValue>, pattern:haxe.macro.Expr) {
		return switch (pattern) {
			case macro $a => $b:
				macro switch ($value) {
					case $a: $b;
					default: throw "no match";
				}
			default:
				var print = new haxe.macro.Printer().printExpr;
				throw new haxe.macro.Expr.Error('Invalid enum value extraction pattern: "${print(pattern)}"', pattern.pos);
		}
	}
}