sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome. friend!  Please seek the words of the clerics of Marr.  Their words are the words which will set us free from the tyranny of the Freeport Militia.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 12130 - Part of Potion of Marr
	if (plugin::check_handin(\%itemcount, 12130 => 1 )) {
		quest::say("I feel quite alert now. Thank you. You should take this to the next sentry.");
		#:: Give item 12131 - Half of Potion of Marr
		quest::summonitem(12131);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(362, 2); 		#:: + Priests of Marr
		quest::faction(330, -1); 		#:: - Freeport Militia
		quest::faction(281, 1); 		#:: + Knights of Truth
		#:: Give a small amount of xp
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
