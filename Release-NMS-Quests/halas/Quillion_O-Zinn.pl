sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Good day to you, $name!  If you are looking for fishing supplies, you've come to the right place. And if you have a successful day, I will gladly pay for your catch.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
