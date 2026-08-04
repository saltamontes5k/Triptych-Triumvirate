sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What do you want?  Can't you see that I wish to be alone?!  I have no need nor desire to speak with anyone.  I have a minor dilemma to ponder and the only person I wish to speak with is the [captain].");
	}
	elsif ($text=~/captain/i) {
		quest::say("If you have to ask that. you should not be in this fine establishment.");
	}
	elsif ($text=~/danaria sent me/i) {
		quest::say("If you are working for Danaria, you have been misguided. You will go back to her empty handed. Now leave. The [captain] and I have some business to discuss.");
	}
	elsif ($text=~/portrait to palatos kynarn/i) {
		quest::say("You have the portrait! Give it to me... <Hic!> Danaria will not get it...");
	}
}

sub EVENT_ITEM {
	#:: Match four 13817 - Capt. Orlin's Spiced Ale
	if (plugin::check_handin(\%itemcount, 13817 => 4)) {
		quest::say("Ahh... I... <Hic!> Need help... <Hic!> You... take this... Go build... boat beacon. <Hic!> Ask gnomes about... <Hic!> boat beacon. They know how... Then bring back... <Hic!> Unnnhh! Prexus help me! I will never drink again.");
		#:: Give item 12145 - Beacon Mount
		quest::summonitem(12145);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 2); 		#:: + Craftkeepers
		quest::faction(266, 1); 		#:: + High Council of Erudin
		quest::faction(265, -1); 		#:: - Heretics
		quest::faction(267, 1); 		#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13818 - Boat Beacon
	elsif (plugin::check_handin(\%itemcount, 13818 => 1)) {
		quest::say("Thanks.. That saved me a lot of money. Now I can spend more time with the captain before I give this back to Lenka Stoutheart. Here is a little so...mething.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 10); 		#:: + Craftkeepers
		quest::faction(266, 1); 		#:: + High Council of Erudin
		quest::faction(265, -1); 		#:: - Heretics
		quest::faction(267, 1); 		#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 900 to 1200cp
		my %cash = plugin::RandomCash(900,1200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 12146 - Ak'Anon's Portrait
	elsif (plugin::check_handin(\%itemcount, 12146 => 1)) {
		quest::say("Wise decision!! Little reward for a large deed. Bye.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 5); 		#:: + Craftkeepers
		quest::faction(266, 1); 		#:: + High Council of Erudin
		quest::faction(265, -1); 		#:: - Heretics
		quest::faction(267, 1); 		#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 900 to 1200cp
		my %cash = plugin::RandomCash(900,1200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You shall soon meet the vengeance of my fellow Craftkeepers and, most likely, of all Erudites.");
}
