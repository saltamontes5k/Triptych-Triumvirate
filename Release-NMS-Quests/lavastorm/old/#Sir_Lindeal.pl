sub EVENT_SPAWN {
	plugin::StraightPath(500,600);
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("In the name of the Rainkeeper, I strike at thee!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	$Random = quest::ChooseRandom(1,2);
	if ($Random == 1) {
		quest::say("You will meet your own doom soon enough, my friend.. my influence with the Knights of Thunder is great, and they will not rest until I am avenged!");
	}
	else {
		quest::say("Karana shall guide the Knights of Thunder to avenge the death of one of his flock.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
