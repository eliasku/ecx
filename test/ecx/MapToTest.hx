package ecx;

import ecx.components.Value;
import utest.Assert;

@:keep
class MapToTest extends EcxTest {

    public function new() {
        super();
    }

    public function testMapTo() {
        var values:MapTo<Value> = world.engine.mapTo(Value);
        var e = world.createEntity();
        var v = e.create(Value);
        Assert.isTrue(v == values[e.id]);
        Assert.isTrue(v == values.get(e.id));
        Assert.isNull(values[0]);
    }
}