sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Who are you? Did McNeal send you? If not, you would do yourself good to leave Gnasher alone. I have friends in high places.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18800 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18800 => 1)) {
		quest::say("Ah. Good for you! Here you are. Take this to McNeal, but next time there will be no stout if there are no weapons.");
		#:: Give a 13131 - Case of Blackburrow Stout
		quest::summonitem(13131);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(223, 5);			#:: + Circle Of Unseen Hands
		quest::faction(291, -1);		#:: - Merchants of Qeynos
		quest::faction(230, 1);			#:: + Corrupt Qeynos Guards
		quest::faction(262, -1);		#:: - Guards of Qeynos
		quest::faction(273, 1);			#:: + Kane Bayle
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
