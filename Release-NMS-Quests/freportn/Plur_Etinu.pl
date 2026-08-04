sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Your soul is welcome in our temple. The Queen of Love, Erollisi Marr, desires more to join our ranks. This city of Freeport must not stay under the control of  the Freeport Militia. I am here to [cure poison] and [cure disease], or if any [need healing].");
	}
	elsif ($text=~/cure poison/i) {
		quest::say("Before the Queen of Passion can force the toxin from your system, I shall require 3 bixie stingers to perform the act.");
	}
	elsif ($text=~/cure disease/i) {
		quest::say("The affliction which has been cast upon you shall be purged from your body, but first I need two portions of zombie flesh to perform the act.");
	}
	elsif ($text=~/need healing/i) {
		quest::say("If it is the power of the passion you require to bind your wounds, then lay down your tribute of 10 gold.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13074 - 2x Zombie Skin
	if (plugin::check_handin(\%itemcount, 13074 => 2 )) {
		quest::say("May the Power of Passion purge you of disease!");
		#:: Cast spell 203 - Cure Poison
		$npc->CastSpell(203,$userid);
		#:: Ding!
		quest::ding();
	}	
	#:: Turn in for 14029 - 3x Bixie Stinger
	elsif (plugin::check_handin(\%itemcount, 14029 => 3 )) {
		quest::say("May the Power of Passion forced you free of poison!");
		#:: Cast spell 203 - Cure Poison
		$npc->CastSpell(203,$userid);
		#:: Ding!
		quest::ding();
	}		
	#:: Match 10 gold pieces
	elsif (plugin::takeCoin(0, 0, 10, 0)) {
		quest::say("May the unbridled passion of Erollisi Marr flow through your body.");
		#:: Cast spell 17 - Light Healing
		$npc->CastSpell(17,$userid);
		#:: Ding!
		quest::ding();
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
