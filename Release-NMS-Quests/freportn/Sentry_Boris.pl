sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Please seek guidance from the clerics within this temple.  I am but a Sentry of Passion and my duty is to protect this temple.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 12128 - Part of Potion of Marr
	if (plugin::check_handin(\%itemcount, 12128 => 1 )) {
		quest::say("Ahhh!! That has given me back lost energy. Thank you. Please take this to the next sentry.");
		#:: Give item 12129 - Part of Potion of Marr
		quest::summonitem(12129);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 2);		#:: + Priests of Marr
		quest::faction(330, -1);	#:: - Freeport Militia
		quest::faction(281, 1);		#:: + Knights of Truth
		#:: Give a small amount of xp
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
