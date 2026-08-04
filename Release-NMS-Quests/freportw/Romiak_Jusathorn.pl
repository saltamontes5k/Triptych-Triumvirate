sub EVENT_ITEM {
	#:: Match a 18741 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18741 => 1 )) {
		quest::say("Greetings, I am Romiak Jusathorn, Master Enchanter of the Academy. Take this.. it's our guild robe; it will help protect you in this harsh environment. Now, let's get to work!");
		#:: Give item 13560 - Old Violet Robe
		quest::summonitem(13560);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(361, 3);	 		#:: + Arcane Scientists
		quest::faction(281, 3); 		#:: + Knights of Truth
		quest::faction(309, 1); 		#:: + Silent Fist Clan
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
