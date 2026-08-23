sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 50 units tall, without proximity say
	quest::set_proximity($x - 25, $x + 25, $y - 25, $y + 25, $z - 25, $z + 25, 0);
}

sub EVENT_ENTER {
	quest::emote("hate this place.");
	quest::depop_withtimer();
}
