sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. stranger. I would talk to thee, but [Barn] has instructed me not to converse with strangers.");
	}
	elsif ($text=~/barn/i) {
		quest::say("Barn is my hero. He saved me from a life on the evil streets in Freeport.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You have no idea what a big mistake you made. Either my fellow rogues shall find you or the Freeport Mi... Unnnghh.");
}
