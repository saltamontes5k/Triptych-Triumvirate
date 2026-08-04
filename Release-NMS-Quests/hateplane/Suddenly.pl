sub EVENT_SPAWN {
	#:: Create a proximity, 50 units across, 50 units tall, without proximity say
	quest::set_proximity($x - 25, $x + 25, $y - 25, $y + 25, $z - 25, $z + 25, 0);
}

sub EVENT_ENTER {
	quest::emote("paranoid,  you look at each of your party members.  Which one will be corrupted first?  Who will die next?  Will one of them fail me?");
	quest::depop_withtimer();
}
