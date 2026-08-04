sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hey friend. nice wallet ya got there.  Bet it's fulla money. huh?  Why don't ya let me take a quick look. huh?");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18923 - Message to Rebby
	if (plugin::check_handin(\%itemcount, 18923 => 1)) {
		#:: Give item 13158 - Rebbys Rat Whiskers
		quest::summonitem(13158);
		#:: Give a small amount of xp
		quest::exp(50);
		#:: Ding!
		quest::ding();
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
