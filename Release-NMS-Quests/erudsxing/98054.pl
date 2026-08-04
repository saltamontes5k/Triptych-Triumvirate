#:: Erud's Crossing >> Golden_Maiden (98054)

sub EVENT_SPAWN {
	#:: Create a proximity, 80 units across, 200 units tall, without proximity say
	quest::set_proximity($x - 30, $x + 30, $y - 30, $y + 30, $z - 100, $z + 100, 0);
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 0
	if ($wp == 0) {
		#:: Create a proximity, 80 units across, 200 units tall, without proximity say
		quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
	}
	#:: Match waypoint 1
	elsif ($wp == 1) {
		quest::clear_proximity();
	}
}

sub EVENT_ENTER {
	#:: Move client to South Qeynos (qeynos)
	quest::movepc(1, 206, 15, 3.75, 128);
}
