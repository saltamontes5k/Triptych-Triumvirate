sub EVENT_SAY {
	if ($text=~/Hail/i) {
		quest::say("Greetings, $name! Welcome to the Academy of Arcane Science. Nowhere on Norrath can you find a greater learning center.");
	}
	if ($text=~/retlon brenclog/i) {
		quest::say("I'm very sorry to report that Retlon was kidnapped by some vile orcs from Crushbone. And I haven't seen him since.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
