sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Time to die $name!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. I am Delharn, from [Freeport]. Im trying to earn some extra coin while passing through Highpass. I figured this is a pretty honorable way to do.");
	}
	elsif ($text=~/freeport/i) {
		quest::say("Freeport? It's the biggest city in all of Antonica. Whatever you're looking for, lest it be peace and quiet, you'll find it in Freeport.");
	}
	elsif ($text=~/highpass/i) {
		quest::say("Sorry, I've only been around here for a little more than a week. Try asking Captain Ashlan there, I bet he'd know.");
	}
	elsif ($text=~/orcs/i) {
		quest::say("These pesky orcs are a bit tougher than the ones I used hunt in [Freeport]. Smell worse, too.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
