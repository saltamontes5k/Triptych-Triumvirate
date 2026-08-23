sub EVENT_SPAWN {
	#:: Set a timer 'help' that loops every 1500 seconds (25 min)
	quest::settimer("help", 1500);
}

sub EVENT_TIMER {
	#:: Match the timer 'help'
	if ($timer eq "help") {
		$Random = quest::ChooseRandom(1,2);
		if ($Random == 1) {
			quest::say("if only someone were to use the lever, we could escape from here and find help.");
		}
		else {
			quest::say("Grrrr. You are a foolish whelp. Be quiet, or the elementals will kill us.");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
