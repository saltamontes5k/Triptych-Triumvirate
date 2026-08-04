sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name!  Welcome to Rivervale!  I hope you plan to stay on and assist us in any way you can.  We all have talents to aid in the prosperity of the hollow.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
