sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, citizen! Welcome to the Freeport Militia House. It is time for you to serve the state. You will assist us in our war with [Clan Deathfist] before you are truly accepted into our city. We urge you to be all we command you to be.'");
	}
	elsif ($text=~/clan deathfist/i) {
		quest::say("Clan Deathfist are the orcs of the Commonlands. They are a nuisance and Sir Lucan has ordered their extermination. You will go forth into the Commonlands and kill these orcs. Clan Deathfis'st members are known to wear a clan belt. Bring a belt to me as proof of each death and you shall receive your wages and prove your allegiance to Freeport and all that is good.");
	}
}

sub EVENT_ITEM {
	#:: Match four 13916 - Deathfist Slashed Belt
	if (plugin::check_handin(\%itemcount, 13916 => 4)) {
		quest::say("Good work, warrior. You are good militia material. Beware though, there are some who dare to call us foe. You have performed so well!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, 20); 		#:: + Freeport Militia
		quest::faction(336, 4); 		#:: + Coalition of Trade Folk Underground
		quest::faction(281, -4); 		#:: - Knights of Truth
		quest::faction(362, -4); 		#:: - Priests of Marr
		#:: Grant a large amount of experience
		quest::exp(4000);
		#:: Create a hash for storing cash - 1000 to 1400cp
		my %cash = plugin::RandomCash(1000,1400);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match three 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 3)) {
		quest::say("Good work, warrior. You are good militia material. Beware though, there are some who dare to call us foe. You have performed so well!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, 15); 		#:: + Freeport Militia
		quest::faction(336, 3); 		#:: + Coalition of Trade Folk Underground
		quest::faction(281, -3); 		#:: - Knights of Truth
		quest::faction(362, -3); 		#:: - Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(3000);
		#:: Create a hash for storing cash - 750 to 1050cp
		my %cash = plugin::RandomCash(750,1050);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match two 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 2)) {
		quest::say("Good work, warrior. You are good militia material. Beware though, there are some who dare to call us foe. You have performed so well!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, 10); 		#:: + Freeport Militia
		quest::faction(336, 2); 		#:: + Coalition of Trade Folk Underground
		quest::faction(281, -2); 		#:: - Knights of Truth
		quest::faction(362, -2); 		#:: - Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(2000);
		#:: Create a hash for storing cash - 500 to 700cp
		my %cash = plugin::RandomCash(500,700);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 1)) {
		quest::say("Good work, warrior. You are good militia material. Beware though, there are some who dare to call us foe. You have performed so well!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, 5); 		#:: + Freeport Militia
		quest::faction(336, 1); 		#:: + Coalition of Trade Folk Underground
		quest::faction(281, -1); 		#:: - Knights of Truth
		quest::faction(362, -1); 		#:: - Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(1000);
		#:: Create a hash for storing cash - 250 to 350cp
		my %cash = plugin::RandomCash(250,350);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	

sub EVENT_DEATH_COMPLETE {
	quest::say("Your name shall be added to the most wanted list of the Freeport Militia!");
}
