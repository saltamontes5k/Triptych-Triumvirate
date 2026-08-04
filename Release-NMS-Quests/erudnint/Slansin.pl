sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings and welcome! Please feel free to look around");
	}
}

sub EVENT_ITEM {
	#:: Match turn in for 13983 - Inert Potion
	if (plugin::check_handin(\%itemcount, 13983 => 1)) {
		#:: Create a scalar variable for mob class
		my $mobclass = $npc->GetClass();
		#:: Match if class is 41 - shopkeeper
		if ($mobclass == 41) {
			quest::say("Thank you. I have been expecting this. We require it for mixing.");
			#:: Give a small amount of xp
			quest::exp(300);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(231, -1);		#:: - Craftkeepers
			quest::faction(266, -1);		#:: - High Council of Erudin
			quest::faction(265, 1);			#:: + Heretics
			quest::faction(267, -1);		#:: - High Guard of Erudin
			#:: Depop no timer
			quest::depop();
		}
		#:: Match if class is 14 - enchanter
		elsif ($mobclass == 14) {
			quest::say("Ha!! What a fool!! I have stolen another potion to add to the crate. I shall make a fortune!! The real Slansin is in back. Now it is time for me to leave.");
			#:: Give a small amount of xp
			quest::exp(300);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(336, 2);			#:: + Coalition of Tradefolk Underground
			quest::faction(229, 2);			#:: + Coalition of Tradefolk
			quest::faction(329, 1);			#:: + Carson McCabe
			quest::faction(230, 1);			#:: + Corrupt Qeynos Guards
			quest::faction(330, 1);			#:: + Freeport Militia
		}
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
