sub EVENT_SPAWN {
	#:: Create a proximity, 80 units across, 80 units tall, without proximity say
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 1
	if ($wp == 1) {
		#:: Create a proximity, 80 units across, 80 units tall, without proximity say
		quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 100, $z + 100, 0);
	}
	#:: Match waypoint 2
	elsif ($wp == 2) {
		quest::clear_proximity();
	}
}

sub EVENT_ENTER {
	quest::emote("'s spirit moves you to another land ...");
	#:: Cast 2279 - Portal to Ocean
	quest::selfcast(2279);
}
