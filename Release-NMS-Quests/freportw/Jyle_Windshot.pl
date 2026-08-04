sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, friend!! Nice to meet you. I see you enjoy barging into other people's rooms. No problem. I enjoy the company. What are you looking for?");
}
	if ($text=~/treant wood/i) {
		#:: Match if faction is better than apprehensive
		if ($faction < 6) {
			quest::say("You are a new courier from the Faydarks. I am sorry I did not stay closer to the docks. I hear that part of Freeport is dangerous and is filled with many rogues. I shall require a new Small Lantern in trade for the Treant Wood.");
		}
		else {
			quest::say("Your ways are considered vile to Faydark's Champions. Leave before my rage overcomes my restraint.");
		}
    }
}

sub EVENT_ITEM {
	#:: Turn in for 13003 Small Lantern
	if (plugin::check_handin(\%itemcount, 13003 => 1)) {
		quest::say("Thanks, friend. I have run a long way to get here in time. Mostly at night. I lost my lantern in a card game in Highkeep.");
		#:: Randomly choose from Wooden Shards 90% chance, or A Wooden Heart 10% chance
		quest::summonitem(quest::ChooseRandom(13824, 13824, 13824, 13824, 13824, 13824, 13824, 13824, 13824, 12334));
		#:: Give a small amount of xp
		quest::exp(500);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(246,1); 		#:: + Faydark's Champions
		quest::faction(279,1); 		#:: + King Tearis Thex
		quest::faction(226,1); 		#:: + Clerics of Tunare
		quest::faction(310,1); 		#:: + Soldiers of Tunare
		quest::faction(234,-1); 		#:: - Crushbone Orcs
	}
	plugin::return_items(\%itemcount);
}
