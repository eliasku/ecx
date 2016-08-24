//package ecx.concept.test;
//
//import ecx.concept.WorldExt.StorageConfig;
//import ecx.WorldConfig;
//import utest.Assert;
//
//class ConceptTest {
//
//	var _ext:WorldExt;
//
//	public function new() {}
//
//	public function setup() {
//		var config = new WorldConfig();
//		config.add(new Name());
//		config.add(new Info());
//		var world = Engine.initialize().createWorld(config);
//		_ext = new WorldExt(world);
//		var storage = new StorageConfig();
//		storage.add(Name);
//		storage.add(Info);
//		_ext.build(storage);
//	}
//
//	public function testWorld() {
//		Assert.notNull(_ext.world);
//		Assert.notNull(_ext.table[0]);
//		Assert.notNull(_ext.table[1]);
//		Assert.isTrue(_ext.table.length == 2);
//		var name:Name = cast _ext.table[Name.CID];
//		var map = name.map();
//		var e1 = @:privateAccess new Entity(0);
//		var e2 = @:privateAccess new Entity(1);
//		name.set(e1, "rocket");
//		Assert.notNull(map[e1.id]);
//		Assert.isNull(map[e2.id]);
//		name.remove(e1);
//		Assert.isNull(name.get(e1));
//	}
//}