sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Nice to meet you, $name. If you are a fellow bard. I must inform you that you will make no profit around here. Not with Guard McCluskey around.");
	}
	elsif ($text=~/guard mccluskey/i) {
		quest::say("'I will tell you no more. I do not wish to end up boxed and buried. Just stay away from Guard McCluskey. He is no honorable man.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
