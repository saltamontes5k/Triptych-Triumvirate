sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings! You will have to excuse me. I have no time to talk right now and I prefer to be left alone. Please leave.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18742 - A tattered note
	if (plugin::check_handin(\%itemcount, 18742 => 1)) {
		quest::say("Welcome to the Guild, here's your guild robe. Now, let's get to work.");
		#:: Give item 13562 - Dark Stained Robe
		quest::summonitem(13562);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(296, 100); 		#:: + Opal Darkbriar
		quest::faction(271, 25); 		#:: + Dismal Rage
		quest::faction(239, 25); 		#:: + The Dead
		quest::faction(238, 25); 		#:: + Dark Reflection
		quest::faction(221, 25); 		#:: + Bloodsabers
		#:: Grant a small amount of experience
		quest::exp(100);
		
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
