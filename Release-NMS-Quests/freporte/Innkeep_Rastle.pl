sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail $name. Business is going well these days. I have a full stock of baked goods and other items for sale. Have a look around!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
