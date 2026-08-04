sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. $name. If you are interested in helping the League of Antonican Bards by delivering some mail you should talk to Ton Twostring.");
	}
} 

sub EVENT_ITEM {
	#:: Match a 18158 - A Bardic Letter (Freeport)
	if (plugin::check_handin(\%itemcount, 18158 => 1)) {
		quest::say("Mail from the front - thank you very much! Please take this gold for your troubles. If you are interested in more work, just ask Ton Twostring");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 100); 		#:: + League of Antonican Bards
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(262, 10); 		#:: + Guards of Qeynos
		quest::faction(304, -30); 		#:: - Ring of Scale
		quest::faction(285, -30); 		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(80);
		#:: Create a hash for storing cash - 600 to 1000cp
		my %cash = plugin::RandomCash(600,1000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 18157 - A Bardic Letter (Freeport)
	elsif (plugin::check_handin(\%itemcount, 18157 => 1)) {
		quest::say("Incoming mail - very good!  Please take this gold for your troubles.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 100); 		#:: + League of Antonican Bards
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(262, 10); 		#:: + Guards of Qeynos
		quest::faction(304, -30); 		#:: - Ring of Scale
		quest::faction(285, -30); 		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(80);
		#:: Create a hash for storing cash - 600 to 1000cp
		my %cash = plugin::RandomCash(600,1000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 18159 - A Bardic Letter (Freeport)
	elsif (plugin::check_handin(\%itemcount, 18159 => 1)) {
		quest::say("'Mail from the front - thank you very much! Please take this gold for your troubles. If you are interested in more work, just ask Ton Twostring.'");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 100); 		#:: + League of Antonican Bards
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(262, 10); 		#:: + Guards of Qeynos
		quest::faction(304, -30); 		#:: - Ring of Scale
		quest::faction(285, -30); 		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 800 to 1200cp
		my %cash = plugin::RandomCash(800,1200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 18155 - A Bardic Letter (Freeport)
	elsif (plugin::check_handin(\%itemcount, 18155 => 1)) {
		quest::say("Incoming mail - very good!  Please take this gold for your troubles.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 100); 		#:: + League of Antonican Bards
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(262, 10); 		#:: + Guards of Qeynos
		quest::faction(304, -30); 		#:: - Ring of Scale
		quest::faction(285, -30); 		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 1100 to 15000cp
		my %cash = plugin::RandomCash(1100,1500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 18166 - Pouch of Mail (Freeport)
	elsif (plugin::check_handin(\%itemcount, 18166 => 1)) {
		quest::say("'Mail from the front - thank you very much! Please take this gold for your troubles. If you are interested in more work, just ask Ton Twostring");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 100); 		#:: + League of Antonican Bards
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(262, 10); 		#:: + Guards of Qeynos
		quest::faction(304, -30); 		#:: - Ring of Scale
		quest::faction(285, -30); 		#:: - Mayong Mistmoore
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 1100 to 15000cp
		my %cash = plugin::RandomCash(1100,1500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
