sub EVENT_SLAY {
	quest::say("Tone deaf fool, you have no ear for rhythm, and deserve this death.");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("The dance is over, for now.");
	#:: Spawn one and only one Plane of Hate >> Hand_of_the_Maestro (76015) at the current location
	#:: After revamp
	#:: quest::unique_spawn(76015, 0, 0, $x, $y, $z);
}
