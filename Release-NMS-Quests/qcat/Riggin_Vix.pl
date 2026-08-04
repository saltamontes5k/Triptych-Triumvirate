sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Be careful down here, $name.  We have seen some strange characters in the Eastern Tunnels.  Some kind of cult members, I think.  Watch out.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
