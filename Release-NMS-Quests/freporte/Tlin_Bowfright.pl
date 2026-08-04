sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Nice to meet you! Sit down! Have some food and grog. Just learn not to annoy anyone in here. This place attracts a pretty rough crowd at times. It is not uncommon to have a brawl break out.");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /freporte/Trolon_Lightleer.pl
	if ($signal == 1) {
		quest::say("I wish the Qeynos Guards would come and conquer Freeport. The Freeport Militia are nothing more than mercenaries and criminals.");
		#:: Send a signal '4' to East Freeport >> Talym_Shoontar (10182) with no delay
		quest::signalwith(10182, 4, 0);
	}
	#:: Match a signal '2' from /freporte/Talym_Shoontar.pl
	elsif ($signal == 2) {
		quest::say("The only blithering fool in here is you, Talym Shoontar.");
		#:: Send a signal '5' to East Freeport >> Talym_Shoontar (10182) with no delay
		quest::signalwith(10182, 5, 0);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
