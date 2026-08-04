sub EVENT_SPAWN {
	#:: Create a proximity, 50 units across, 50 units tall, without proximity say
	quest::set_proximity($x - 25, $x + 25, $y - 25, $y + 25, $z - 25, $z + 25, 0);
}

sub EVENT_ENTER {
	quest::emote("with rage, you can hardly wait until you are able to spill blood again.  In fact, you might not wait!  You never did like the way that person over there looked at you!");
	quest::depop_withtimer();
}
