sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings! You will have to excuse me. I have no time to talk right now and I prefer to be left alone. Please leave.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18739 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18739 => 1)) {
		quest::say("Welcome to the Academy of Arcane Sciences. Here's one of our guild robes for you to wear. Now, let's get to work.");
		#:: Give a 13558 - Patched Violet Robe
		quest::summonitem(13558);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(296, -15); 		#:: - Opal Dark Briar
		quest::faction(220, 100); 		#:: + Arcane Scientists
		quest::faction(281, 25); 		#:: + Knights of Truth
		quest::faction(330, -15); 		#:: - The Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
