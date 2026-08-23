sub EVENT_SPAWN {
	quest::set_proximity($x - 25, $x + 25, $y - 25, $y + 25, $z - 10, $z + 10);
}

sub EVENT_ENTER {
	quest::movepc(80, 36, 262, 1.50, 380.5);
}
