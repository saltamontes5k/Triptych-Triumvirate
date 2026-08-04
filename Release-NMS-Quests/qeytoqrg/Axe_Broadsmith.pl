sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. The fishing is sparse here. You would fare better at [Lake Rathe].");
	}
	elsif ($text=~/lake rathe/i) {
		quest::say("Beyond the Plains of Karana can be found a pass to Lake Rathe. I have heard stories of a giant water beast and underwater cities. I wish I knew how to swim.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18893 - Sealed Letter
	if (plugin::check_handin(\%itemcount, 18893 => 1)) {
		quest::say("So you are the new warrior. Let us test your skill. Across the pond is a skeleton. See him? Engage him in combat. He awaits. Return his skull to me and I shall call you a Steel Warrior. Be quick. He will dissipate soon.");
		#:: Ding
		quest::ding();
		#:: Set factions
		quest::faction(311, 2);			#:: + Steel Warriors
		quest::faction(262, 1);			#:: + Guards of Qeynos
		quest::faction(230, -1);		#:: - Corrupt Qeynos Guards
		quest::faction(330, -1);		#:: - The Freeport Militia
		quest::faction(281, 1);			#:: + Knights of Truth
		#:: Spawn one and only one The Qeynos Hills >> a_strange_skeleton (4192)
		quest::unique_spawn(4192, 0, 0, 1055, 3858, -19);
	}
	#:: Match a 13397 - Skull
	elsif (plugin::check_handin(\%itemcount, 13397 => 1)) {
		quest::say("So you have returned. Victory is yours, young Steel Warrior. Take this letter of recommendation to Brin Stolunger at the arena in Qeynos. You have passed.");
		#:: Give a 18895 - Letter of Recommendation
		quest::summonitem(18895);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(311, 5);			#:: + Steel Warriors
		quest::faction(262, 1);			#:: + Guards of Qeynos
		quest::faction(230, -1);		#:: - Corrupt Qeynos Guards
		quest::faction(330, -1);		#:: - The Freeport Militia
		quest::faction(281, 1);			#:: + Knights of Truth
		#:: Grant a moderate amount of experience
		quest::exp(6000);
		#:: Create a hash for storing cash - 5 to 10cp
		my %cash = plugin::RandomCash(5,10);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
