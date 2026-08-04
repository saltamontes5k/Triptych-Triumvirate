sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hey, hello there, $name. It's been so busy around here lately! Barely time to eat and sleep, let alone have any fun. Oh well, it keeps me employed. But, I really could use someone to [help] me out around here.");
	}
	elsif ($text=~/help/i) {
		quest::say("Yea and if you can help me out with A few things that'd be great. Geez and where do we Start? I need someone to run over to [Janam and Rebby's]? Can you do that for me?");
	}
	elsif ($text=~/janam and rebby/i) {
		quest::say("Janam and Rebby are A couple of merchants working the area around the Theater of the Tranquil and the Ashen Order, in West Freeport. It's part of my job to keep tabs on those two rascals. I need someone to take this note to Rebby for me. Don't worry, your efforts won't go unnoticed $name");
		#:: Give a 18923 - Message to Rebby
		quest::summonitem(18923);
	}
}

sub EVENT_ITEM {
	#:: Match a 13158 - Rebby's Rat Whiskers
	if (plugin::check_handin(\%itemcount, 13158 => 1)) {
		quest::say("Thank you $name, You have done well.");
		#:: Ding!
		quest::ding();
		#:: Set faction	
		quest::faction(336, 10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 10); 		#:: + Coalition of Trade Folk
		quest::faction(329, 1); 		#:: + Carson McCabe
		quest::faction(230, 1); 		#:: + Corrupt Qeynos Guards
		quest::faction(330, 1); 		#:: + Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 5 to 15cp
		my %cash = plugin::RandomCash(5,15);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
