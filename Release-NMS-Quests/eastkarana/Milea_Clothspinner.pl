sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, fellow adventurer. Are you from Qeynos?");
	}
}

sub EVENT_ITEM {
	#:: Match a 18801 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18801 => 1)) {
		quest::say("My sister is in danger. She is all the family I have left. I shall be on my way soon. Please take her my handkerchief, so she knows you have contacted me. Thank you. I am thankful Nerissa ran into you. I just wonder why she did not tell Kane about her suspicions.");
		#:: Give a 13302 - Monogrammed Cloth
		quest::summonitem(13302);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(311, 10);		#:: + Steel Warriors
		quest::faction(262, 2);			#:: + Guards of Quenos
		quest::faction(230, -1);		#:: - Corrupt Qeynos Guards
		quest::faction(330, -1);		#:: - Freeport Militia
		quest::faction(281, 2);			#:: + Knights of Truth
		#:: Grant a moderate amount of experience
		quest::exp(2000);
		#:: Spawn one and only one 15193 - Eastern Plains of Karana >> #Guard_Elias, on grid 135, no guildwar, at the specified coordinates
		quest::unique_spawn(15193, 135, 0, -5521, -1870, 3, 226);
	}
	#:: Match a 18934 - Sealed Note, filename='LoveToMilea'
	elsif (plugin::check_handin(\%itemcount, 18934 => 1)) {
		quest::say("Oh great!! I thought I'd saw that last of Plagus, or as all the women in the Steel Warriors called him, the Plague. Please do not tell him where I am. It must have been a long journey for you. Here. A little something for your wasted trip. I found it on the ground. Have fun going back to Freeport.");
		#:: Give a random reward: 3040 - Blackened Iron Coif, 5231 - Black Wolf Crown, 1037 - Fur Lined Shoes, 17005 - Backpack, 13003 - Small Lantern, 10008 - Gold Ring, 1005 - Cloth Shawl, 8791 - Ruined Rawhide Leggings, 1336 - Damask Cape, 2910 - Grizzly Hide Cloak
		quest::summonitem(quest::ChooseRandom(3040, 5231, 1037, 17005, 13003, 10008, 1005, 8791, 1336, 2910));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(311, 5);			#:: + Steel Warriors
		quest::faction(262, 1);			#:: + Guards of Quenos
		quest::faction(230, -1);		#:: - Corrupt Qeynos Guards
		quest::faction(330, -1);		#:: - Freeport Militia
		quest::faction(281, 1);			#:: + Knights of Truth
		#:: Grant a moderate amount of experience
		quest::exp(2000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
	#:: Match a signal "1" from Eastern Plains of Karana >> #Guard_Elias (15193)
	if ($signal == 1) {
		quest::say("Get out of here! It is time I dealt with this traitorous guard. Okay guard, let's get it on!!");
		#:: Send a signal "1" to Eastern Plains of Karana >> #Guard_Elias (15193) with 5 second delay
		quest::signalwith(15193, 1, 5);
	}
}
