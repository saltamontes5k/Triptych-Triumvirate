#:: Erud's Crossing >> Sea_King (98053)

sub EVENT_SPAWN {
	#:: Create a proximity, 80 units across, 200 units tall, without proximity say
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 22
	if ($wp == 22) {
		#:: Create a proximity, 80 units across, 200 units tall, without proximity say
		quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
	}
	#:: Match waypoint 23
	elsif ($wp == 23) {
		quest::clear_proximity();
	}
}

sub EVENT_ENTER {
	#:: Move client to Erudin (erudnext)
	quest::movepc(24, -337, 108, 23.75, 85);
}
