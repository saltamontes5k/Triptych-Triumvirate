sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail!! If you be a new reserve member then show me your Militia Armory Token. If you are not yet initiated then I suggest you head to the Toll Gate in the Commonlands and speak with Guard Valon.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 12273 - Militia Armory Token
	if (plugin::check_handin(\%itemcount, 12273 => 1 )) {
		quest::say("Welcome to the Freeport Militia. As a reserve member we require you to wear this tunic and fight when, who and wherever Sir Lucan commands, no questions asked!! There is no turning back!! Remember to keep clear of North Freeport. You have made a wise decision. Hail Sir Lucan!!");
		#:: Grant a large amount of xp
		quest::exp(10000);
		#:: Ding!
		quest::ding();
		#:: Give item 3097 - Reserve Militia Tunic
		quest::summonitem(13097);
		#:: Set faction
		quest::faction(330, 10); 		#:: + Freeport Militia
		quest::faction(336, 10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, -30); 		#:: - Knights of Truth
		quest::faction(362, -30); 		#:: - Priests of Marr
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
