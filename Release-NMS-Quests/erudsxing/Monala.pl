sub EVENT_SPAWN {
	#:: Create a proximity, 80 units across, 200 units tall, without proximity say
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
}

sub EVENT_ENTER {
	#:: Our boats are docked and Monala explains what to do.  This is not original.
	quest::say("Hello, $name. The seas run high today!  Hop on the Golden Maiden to the South for Qeynos; the Sea King to the North for Erudin. Way, hey, blow the man down!");
}
