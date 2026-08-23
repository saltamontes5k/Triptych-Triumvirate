sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Ah.. Hello citizen.. Watch your step, there have been many vicious beasts about today.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18823 - Note to Neclo
	if (plugin::check_handin(\%itemcount, 18823 => 1)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Ah.. Hello friend.. So, I see Daenor sent you.. Uh huh, ok.. Here's something that will be very useful for you. Practice this well, friend.. It will help protect you in this harsh world.");
			#:: Give a 15109 - Spell: Elemental Armor
			quest::summonitem(15109);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(342, 5);			#:: + Order of Three
			quest::faction(221, -1);		#:: - Bloodsabers
			quest::faction(262, 1);			#:: + Guards of Qeynos
			quest::faction(296, -1);		#:: - Opal Dark Briar
			#:: Grant a moderate amount of experience
			quest::exp(1000);
		}
		else {
			quest::say("The Order of Three has been monitoring your recent activities, and we are appalled by you and your actions! Now, begone!");
			#:: Return a a 18823 - Note to Neclo
			quest::summonitem(18823);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
