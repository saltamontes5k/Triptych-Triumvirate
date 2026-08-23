sub EVENT_SPAWN {
	#:: Start NPC running
	quest::SetRunning(1);
}

sub EVENT_AGGRO {
	quest::say("Fool!  The dark elves will slay you for interfering with my duties!");
}
