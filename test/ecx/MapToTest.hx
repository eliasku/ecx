package ecx;

import ecx.components.Value;
import utest.Assert;

@:keep
class MapToTest extends EcxTest {

    public function new() {
        super();
    }

    public function testMapTo() {
        var values:Value = world.resolve(Value);

        var entity = world.create();
        var emptyEntity = world.create();

        //var data = world.edit(entity);
        var value = values.create(entity);

        //Assert.isTrue(value == values[entity]);
        Assert.isTrue(value == values.get(entity));
        Assert.isNull(values.get(emptyEntity));
    }
}