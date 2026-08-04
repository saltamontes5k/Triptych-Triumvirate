sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to Top of the World, the newest shop in the pass!");
	}
	elsif ($text=~/never stop chopping/i) {
		quest::say("Never stop chopping?!!' Hey! I engraved that on a special order for a fellow Highpass citizen. I can't remember his name. He gave me not only some rare gems for it, but also a case of something called 'Lumberjack Pale Ale.' Great stuff!!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
