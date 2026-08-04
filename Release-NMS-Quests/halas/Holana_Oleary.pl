sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hmph. Hello, $name, how are ye an' how do ye do? Now, what are ye planning to buy?");
		#:: Send a signal '1' to Halas >> Murtog_MacYee (29043)
		quest::signalwith(29043, 1, 1);
	}
	elsif ($text=~/assist/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("So, ye're the next to be tested, then, eh?! I pray ye're able to return. Ye'll need to take this note to Einhorst in Clan McMannus' fishing village in the Plains o' Karana. He'll hand ye the monthly Karana clover shipment to be returned to me. Just remember, dinnae stop running! Do ye [need directions to Clan McMannus]?");
			#:: Give a 18831 - Tattered Note
			quest::summonitem(18831);
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
	elsif ($text=~/need directions to clan mcmannus/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Ye go through Everfrost Peaks and run through Blackburrow. Once in Qeynos Hills, ye'll head to yer left and follow the pathway to the Plains of Karana. In the plains, when the pathway splits, go to yer right. Then just head toward the horizon.");
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13962 - Karana Clover Shipment
	if (plugin::check_handin(\%itemcount, 13962 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Good work. We Shamans o' Justice are like no other. We must remain in top physical form for we never know when justice must be served. I was commanded to give ye a reward. Take this. It was doing nothing more than collecting dust. Go, and serve justice well.");
			#:: Give a random reward: 15270 - Spell: Drowsy, 15275 - Spell: Frost Rift, 15075 - Spell: Sicken, 15271 - Spell: Fleeting Fury, 15279 - Spell: Spirit of Bear, 15212 - Spell: Cure Blindness, 15079 - Spell: Spirit Sight, 15274 - Spell: Scale Skin, 15272 - Spell: Spirit Pouch
			#:: 2031 - Large Leather Belt, 2036 - Large Leather Boots, 2030 - Large Leather Cloak, 2034 - Large Leather Gloves, 2027 - Large Leather Gorget, 2038 - Large Leather Kilt, 2026 - Large Leather Mask, 2029 - Large Leather Shoulderpads, 2025 - Large Leather Skullcap, 2032 - Large Leather Sleeves, 2028 - Large Leather Tunic, 2033 - Large Leather Wristbands
			#:: 2912 - Polar Bear Cloak, 5043 - Tarnished Axe, 6032 - Tarnished Flail, 6030 - Tarnished Mace, 7022 - Tarnished Shortened Spear, 7024 - Tarnished Spear, 6031 - Tarnished Warhammer
			quest::summonitem(quest::ChooseRandom(15270, 15275, 15075, 15271, 15279, 15212, 15079, 15274, 15272, 2031, 2036, 2030, 2034, 2027, 2038, 2026, 2029, 2025, 2032, 2028, 2033, 2912, 5043, 6032, 6030, 7022, 7024, 6031, 2912));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(327, 10);		#:: + Shamen of Justice
			quest::faction(328, 1);			#:: + Merchants of Halas
			quest::faction(223, -1);		#:: - Circle of Unseen Hands  
			quest::faction(336, -1);		#:: - Coalition of Tradefolk Underground 
			quest::faction(244, -2);		#:: - Ebon Mask
			#:: Grant a moderate amount of experience
			quest::exp(1600);
			#:: Create a hash for storing cash - 300 to 900 cp
			my %cash = plugin::RandomCash(300,900);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
			#:: Return a 13962 - Karana Clover Shipment
			quest::summonitem(13962);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
