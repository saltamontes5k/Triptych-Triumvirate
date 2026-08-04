sub EVENT_ITEM {
	#:: Turn in for 13861 - A jar of liquid
	if (plugin::check_handin(\%itemcount, 13861 => 1 )) {
		quest::emote("darts into the jar, or just darted past it!! The Knights of Truth do not tolerate people attempting to catch these fish!!");
		#:: Give a random reward: 13861 - A Jar of Liquid, or 13862 - Fish in a Jar
		quest::summonitem(quest::ChooseRandom(13861,13862));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 1);			#:: + Dismal Rage
		quest::faction(281, -2);		#:: - Knights of Truth
		quest::faction(330, 1);			#:: + The Freeport Militia
		quest::faction(362, -2);		#:: - Priests of Marr
		quest::faction(311, -2);		#:: - Steel Warriors
	}
	#:: Return unused items
    plugin::return_items(\%itemcount);quest::summonitem(quest::ChooseRandom($item1));
}
