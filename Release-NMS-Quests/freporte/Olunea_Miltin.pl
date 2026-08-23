sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. It is good to meet you. Try not to scare the fish away. This is A good spot I supply fish to the Grub N' Grog. The patrons there love me!");
	}
	elsif ($text=~/fish/i) {
		quest::say("I am doing exceptionally well. This harbor is filled with fish. After an hour I have enough to feed me and my family for a week.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13922 - Snapped Pole
	if (plugin::check_handin(\%itemcount, 13922 => 1)) {
		quest::say("Great! Thank you stranger. The rogues must have broken it. At least I could repair it. It would be seasons before I could afford another pole.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, 5); 		#:: + The Freeport Militia
		quest::faction(336, 1); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, -1);	 	#:: - Knights of Truth
		quest::faction(362, -1); 		#:: - Priests of Marr
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 10 to 20cp
		my %cash = plugin::RandomCash(10,20);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
