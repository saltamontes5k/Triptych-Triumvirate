sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hi, I'm Captain Orben, and I'm in charge of the troops and [volunteers] here at the Highpass West Gate. If you'd like to help us out, I'll pay you for every [gnoll] scalp you return to me.");
	}
	elsif ($text=~/volunteer/i) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			quest::say("We set up this Volunteer Watch to help keep these beasts outta Highpass Hold. We get volunteers to stand watch at the gates, and pay them a small reward for every [gnoll] scalp they turn in.");
		}
	}
	elsif ($text=~/gnoll/i) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			quest::say("Well, these [Gnolls] keep sending small raiding parties into Highpass. Thanks to the [Volunteer Watch], and myself, they never get past these gates. Sure keeps us busy, though.");
		}
	}
}	

sub EVENT_ITEM {
	#:: Match four 13792 - Gnoll Scalp
	if (plugin::check_handin(\%itemcount, 13792 => 4)) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			#:: He says nothing.
			#:: Set factions
			quest::faction(332, 8);		#:: + Highpass Guards
			quest::faction(329, 4);		#:: + Carson McCabe
			quest::faction(331, 4);		#:: + Merchants of Highpass
			quest::faction(230, 4);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 4);		#:: + The Freeport Militia
			#:: Grant a small amount of experience, based on level
			$client->AddLevelBasedExp(4, 14);
			#:: Create a hash for storing cash - 1600 to 2000cp
			my %cash = plugin::RandomCash(1600,2000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Else eat items (cannot find text)
	}
	#:: Match three 13792 - Gnoll Scalp
	elsif (plugin::check_handin(\%itemcount, 13792 => 3)) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			#:: He says nothing.
			#:: Set factions
			quest::faction(332, 6);		#:: + Highpass Guards
			quest::faction(329, 3);		#:: + Carson McCabe
			quest::faction(331, 3);		#:: + Merchants of Highpass
			quest::faction(230, 3);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 3);		#:: + The Freeport Militia
			#:: Grant a small amount of experience, based on level
			$client->AddLevelBasedExp(3, 14);
			#:: Create a hash for storing cash - 1200 to 1500cp
			my %cash = plugin::RandomCash(1200,1500);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
	}
	#:: Match two 13792 - Gnoll Scalp
	elsif (plugin::check_handin(\%itemcount, 13792 => 2)) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			#:: He says nothing.
			#:: Set factions
			quest::faction(332, 4);		#:: + Highpass Guards
			quest::faction(329, 2);		#:: + Carson McCabe
			quest::faction(331, 2);		#:: + Merchants of Highpass
			quest::faction(230, 2);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 2);		#:: + The Freeport Militia
			#:: Grant a small amount of experience, based on level
			$client->AddLevelBasedExp(2, 14);
			#:: Create a hash for storing cash - 800 to 1000cp
			my %cash = plugin::RandomCash(800,1000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
	}
	#:: Match one 13792 - Gnoll Scalp
	elsif (plugin::check_handin(\%itemcount, 13792 => 1)) {
		#:: Match if faction is Dubious or better
		if ($faction <= 7) {
			#:: He says nothing.
			#:: Set factions
			quest::faction(332, 2);		#:: + Highpass Guards
			quest::faction(329, 1);		#:: + Carson McCabe
			quest::faction(331, 1);		#:: + Merchants of Highpass
			quest::faction(230, 1);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 1);		#:: + The Freeport Militia
			#:: Grant a small amount of experience, based on level
			$client->AddLevelBasedExp(1, 14);
			#:: Create a hash for storing cash - 400 to 500cp
			my %cash = plugin::RandomCash(400,500);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
	}	
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
