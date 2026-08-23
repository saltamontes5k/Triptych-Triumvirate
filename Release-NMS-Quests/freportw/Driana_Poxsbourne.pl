sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail! $name, You best not be associating yourself with the likes of Najena.");
	}
	elsif ($text=~/reagent/i) {
		quest::say("The infamous Mage, Najena employs several apprentices. These apprentices are most likely well equiped with just the reagents I need. Perhaps you can relieve them of their burden for me? Bring me 3 pouches of reagents from the Mages and you'll have the substance.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 1797 - Reagent Pouch x3
	if (plugin::check_handin(\%itemcount, 1797 => 3)) {
		quest::say("Ahh wonderful work $name Here is the substance....don't spill it HAHAHAaahhahehehe...yes......you don't want to spill that heheh..");
		#:: Give a small amount of xp
		quest::exp(200);
		#:: Ding!
		quest::ding();
		#:: Summon 1793 Putrid Substance
		quest::summonitem(11793);
		#:: Set faction
		quest::faction(221, 1); 			#:: + Bloodsabers
		quest::faction(296, 1); 		#:: + Opal Dark Briar
		quest::faction(230, 1); 			#:: + Corrupt Qeynos Guards
		quest::faction(262, -1); 		#:: - Guards of Qeynos
		quest::faction(341, -1); 		#:: - Priests of Life
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
