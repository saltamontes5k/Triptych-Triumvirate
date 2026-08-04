sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name! I patrol Halas to insure the safety of the travelers and the resident clans.  Just ask if you need help in finding your destination.");
	}
	elsif ($text=~/shaman of justice/i) {
		quest::say("The Shamans of Justice serve the will of the Tribunal. They search out those who defy the laws set by the Tribunal.");
	}
	elsif ($text=~/wolves of the north/i) {
		quest::say("The Wolves of the North comprise of warriors. It is their sole purpose to defend the city and its visitors from all those that would harm it.  Becoming a warrior and thus a Wolve of the North hold the highest form of honor among the clans.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
