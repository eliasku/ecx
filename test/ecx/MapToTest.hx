package ecx;

import ecx.components.Value;
import utest.Assert;

@:keep
class MapToTest extends EcxTest {

    public function new() {
        super();
    }

    public function testMapTo() {
        var values:MapTo<Value> = world.mapTo(Value);

        var entity = world.create();
        var emptyEntity = world.create();

        var data = world.edit(entity);
        var v = data.create(Value);

        Assert.isTrue(v == values[entity]);
        Assert.isTrue(v == values.get(entity));
        Assert.isNull(values.get(emptyEntity));
    }
}