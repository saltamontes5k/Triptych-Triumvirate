sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. Might I ask what you are looking for?");
	}
	elsif ($text=~/treant wood/i) {
		quest::say("You are a new courier from the Faydarks. I am sorry I did not stay closer to the docks. I hear that part of Freeport is dangerous and is filled with many rogues. I shall require a new Small Lantern in trade for the Treant Wood.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13003 - Small Lantern
	if (plugin::check_handin(\%itemcount, 13003 => 1)) {
		quest::say("Thanks, friend. I have run a long way to get here in time. Mostly at night. I lost my lantern in a card game in Highkeep.");
		#:: Randomly choose from Wooden Shards 90% chance, or A Wooden Heart 10% chance
		quest::summonitem(quest::ChooseRandom(13824, 13824, 13824, 13824, 13824, 13824, 13824, 13824, 13824, 12334));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 1); 		#:: + Faydark's Champions
		quest::faction(279, 1); 		#:: + King Tearis Thex
		quest::faction(226, 1); 		#:: + Clerics of Tunare
		quest::faction(310, 1); 		#:: + Soldiers of Tunare
		quest::faction(234, -1); 		#:: - Crushbone Orcs
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
