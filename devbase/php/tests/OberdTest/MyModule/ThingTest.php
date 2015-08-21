<?php

namespace OberdTest\MyModule;

use Oberd\MyModule\Thing;

class ThingTest extends \PHPUnit_Framework_TestCase {
    public function test_SayHello() {
        $thing = new Thing();
        $this->assertEquals("world", $thing->hello());
    }
}
