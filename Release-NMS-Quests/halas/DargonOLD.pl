sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello there, $name.  Can I interest you in any components to help you in your research?");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
