package ecx.macro;

#if macro

/**
	Thanks to @nadako
	- https://gist.github.com/nadako/3db9c067a4e93d64d1f4
**/
@:final
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

#end