sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $Name. Rueppy's my name. Why don't you buy us something to [drink] and we can talk?");
	}
	if ($text=~/drink/i) {
		quest::say("How about a short beer? That sounds good.");
	}
	if ($text=~/blackburrow stout/i) {
		quest::say("Oh, well we can't get that here. However, you can always [smuggle] it in...");
	}
	if ($text=~/smuggle/i) {
		quest::say("Well, that depends. Do you want a [job]?");
	}
	if ($text=~/job/i) {
		quest::say("Should you choose to accept, you have to go to the ruins on the other side of the great wall, find Gunrich, and tell him that Dark Rivers Flow East.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13032 - Short Beer
	if (plugin::check_handin(\%itemcount, 13032 => 1 )) {
		quest::say("Mmm. It's good, but not as good as [Blackburrow Stout].");
		#:: Ding!
		quest::ding();
		#:: Give a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 1 to 10cp
		my %cash = plugin::RandomCash(1,10);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Turn in for 13131 - Case of Blackburrow Stout
	elsif (plugin::check_handin(\%itemcount, 13131 => 1 )) {
		quest::say("Heh heh! You did it! I thought the deputies would get you for sure! I mean... You did it! Heh! Here buy yourself a drink on me.");
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 1 to 20cp
		my %cash = plugin::RandomCash(1,20);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(241, 10);		#:: + Deeppockets
		quest::faction(223, 1);		#:: + Circle of Unseen Hands
		quest::faction(292, -1); 	#:: - Merchants of Rivervale
		quest::faction(336, 1);		#:: + Coalition of Tradefolk Underground
		quest::faction(329, 1);		#:: + Carson McCabe	
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
