sub EVENT_ITEM {
	#:: Match a 18740 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18740 => 1)) {
		quest::say("Welcome to the Academy of Arcane Sciences. I am Lorme Tredore, Master Magician. Here is our guild robe, wear it with pride and represent us well, young $name. Now, let's get to work.");
		#:: Give a 13559 - Used Violet Robe*
		quest::summonitem(13559);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 100);	 	#:: + Arcane Scientists
		quest::faction(281, 25); 		#:: + Knights of Truth
		quest::faction(296, -15); 		#:: - Emerald Warriors
		quest::faction(330, -15); 		#:: - The Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13951 - Fleshy Orb
	elsif (plugin::check_handin(\%itemcount, 13951 => 1)) {
		quest::say("Ah. Thank you for bringing this to me! I will make very good use of it. Here take this small token of my appreciation in return. Guard Jenkins will no longer require it as he was killed on the training field yesterday. Tsk. tsk. tsk.");
		#:: Choose a random reward: 5353 - Fine Steel Scimitar, 5351 - Fine Steel Two Handed Sword, 6351 - Fine Steel Morning Star, 6350 - Fine Steel Warhammer, 7352 - Fine Steel Rapier, 6352 - Fine Steel Great Staff
		quest::summonitem(quest::ChooseRandom(5353, 5351, 6351, 6350, 7352, 6352));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
