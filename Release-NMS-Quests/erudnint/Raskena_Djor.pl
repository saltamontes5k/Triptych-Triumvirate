sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. What brings you to Raskena? Did Ghanlin send you?");
	}
	if ($text=~/ghanlin/i) {
		quest::say("Then let us begin your first task. I require some components for an experiment I have been meaning to conduct. If you could [gather] them for me, I will make sure that you are rewarded."); 
	}
	if ($text=~/gather/i) {
		quest::say("In Toxxulia Forest you should be able to find some fire beetles. I require two fire beetle legs and two fire beetle eyes. Once you have collected them, bring them to me for your reward.");
	}
}

sub EVENT_ITEM {
	#:: Match turn in for 10307 - Fire Beetle Eye and 13250 - Fire Beetle Leg
	if (plugin::check_handin(\%itemcount, 10307 => 2, 13250 => 2)) {
		quest::say("You have passed your first task. Nice work. Take this spell as your payment.");
		#:: Randomly reward 15373 - Spell: Sphere of Light, 15054 - Spell: Frost Bolt, 15205 - Spell: True North, 15288 - Spell: Minor Shielding, 15372 - Spell: Blast of Cold, 15374 - Spell: Numbing Cold
		quest::summonitem(quest::ChooseRandom(15373, 15054, 15205, 15288, 15372, 15374));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of XP
		quest::exp(100);
	}
	plugin::return_items(\%itemcount);
}
