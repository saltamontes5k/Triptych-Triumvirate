sub EVENT_SPAWN {
	quest::set_proximity($x - 60, $x + 60, $y - 60, $y + 60, $z - 80, $z);
}

sub EVENT_ENTER {
	quest::movepc(45, 80, 860, -38);
}
