sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hey!! I don't have any spare change, okay?!");
	}
	elsif ($text=~/testament of vanear/i) {
		quest::say("So you heard Guard Dyllin has page 30 of the Testament of Vanear, eh?! Well, get lost!! Over my dead body will you get page 30!");
		quest::attack($name);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
