sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I welcome you to the Temple of Marr. home to clerics of the deities Erollisi and Mithaniel Marr.  Please seek guidance from the clerics.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 12129 - Part of Potion of Marr
	if (plugin::check_handin(\%itemcount, 12129 => 1 )) {
		quest::say("Excellent!! I feel quite refreshed with but a sip. You may take this to the next sentry.");
		#:: Give item 12130 - Part of Potion of Marr
		quest::summonitem(12130);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 2); 		#:: + Priests of Marr
		quest::faction(330, -1);	 	#:: - Freeport Militia
		quest::faction(281, 1); 		#:: + Knights of Truth
		#:: Give a small amount of xp
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
