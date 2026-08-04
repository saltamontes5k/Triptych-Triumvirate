sub EVENT_SPAWN {
	quest::shout("You cannot escape the claws of Splitpaw! <BARK!>");
	#:: Send a signal '1' to The Western Plains of Karana >> Yiz_Pon (12167) with no delay
	quest::signalwith(12167, 1, 0);
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /qey2hh1/Yiz_Pon.pl
	if ($signal == 1) {
		quest::say("<BARK!> <BARK!> <BARK!> <GRRRRR!>");
		quest::attacknpctype(12167);
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My Splitpaw Clan brothers will tear you to shreds one day! <BARK!>");
}
