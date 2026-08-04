sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name! Has Lanken sent you to see me? Are you a [visitor or citizen of Erudin]?");
	}
	elsif ($text=~/citizen/i) {
		quest::say("Well then you should know better than to speak the name of defilers inside the palace walls. I must get back to my work or I shall be late to the Inn this evening.");
	}
	elsif ($text=~/visitor/i) {
		quest::say("Then, remember, inside the palace walls, never speak the names of those defilers who have passed on. I shall be at the Vasty Inn later tonight. I can answer your questions there.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::returnUnusedItems();
}
