sub EVENT_SPAWN {
	#:: Running true (run)
	quest::SetRunning(1);
}

sub EVENT_AGGRO {

quest::say("In the name of the Rainkeeper, I strike at thee!!");
}

sub EVENT_DEATH_COMPLETE {

quest::say("You will meet your own doom soon enough, my friend.. my influence with the Knights of Thunder is great, and they will not rest until I am avenged!");
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("No time to talk!! I must be off. The grains of sand are falling and I must prove that we paladins from the Temple of Thunder are the quickest.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
