sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("grumbles and looks up at you.");
	}
	else {
		quest::say("Listen, $name. I don't want to be rude, but these fields don't tend to themselves, you know.  I don't have time for your little questions. Go talk to Tiny if you are feeling chatty.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
