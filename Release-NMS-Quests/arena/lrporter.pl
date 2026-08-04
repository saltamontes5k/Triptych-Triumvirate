sub EVENT_SPAWN {
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 40, $z + 40);
}

sub EVENT_ENTER {
	quest::movepc(51, 2676, 2353, 96, 510);
}
