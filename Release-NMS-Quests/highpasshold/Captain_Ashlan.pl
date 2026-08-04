sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, traveler! I am Captain Ashlan of the Highpass Guards. I keep watch over my men and the [volunteers] here at the East Gate. It's been a busy [job] here lately, with the [orc raids] and all.");
	}
	elsif ($text=~/volunteer/i) {
		#:: Match if faction is apprehensive or better
		if ($faction <= 6) {
			quest::say("The Volunteer Watch guards the entry gates of Highpass. Since the [orc raids] are becoming more and more frequent, it's a busy job. But it can pay well, depending on how many [orcs] you slay.");
		}
	}
	elsif ($text=~/job/i) {
		#:: Match if faction is apprehensive or better
		if ($faction <= 6) {
			quest::say("We're short-handed around here, as usual. Would you like to help us out with the [Volunteer Watch]?");
		}
	}
	elsif ($text=~/orc/i) {
		#:: Match if faction is apprehensive or better
		if ($faction <= 6) {
			quest::say("One of the orc clans of Kithicor Woods has been trying to expand their territory. Small orc raiding parties are frequently rushing the East Gate. Without the [Volunteer Watch] helping us out, Highpass would probably be overrun by those vile beasts.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match four 13791 - Orc Scalp
	if (plugin::check_handin(\%itemcount, 13791 => 4)) {
		#:: Match if faction is Apprehensive or better
		if ($faction <= 6) {
			quest::say("Great work. Maybe you can help us out again sometime?");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(332, 8);		#:: + Highpass Guards
			quest::faction(329, 4);		#:: + Carson McCabe
			quest::faction(331, 4);		#:: + Merchants of Highpass
			quest::faction(230, 4);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 4);		#:: + The Freeport Militia
			#:: Grant a small amount of experience
			$client->AddLevelBasedExp(4, 16);
			#:: Create a hash for storing cash - 2000 to 2200cp
			my %cash = plugin::RandomCash(2000,2200);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Else eat the items
	}
	#:: Match three 13791 - Orc Scalp
	elsif (plugin::check_handin(\%itemcount, 13791 => 3)) {
		#:: Match if faction is Apprehensive or better
		if ($faction <= 6) {
			quest::say("Great work. Maybe you can help us out again sometime?");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(332, 6);		#:: + Highpass Guards
			quest::faction(329, 3);		#:: + Carson McCabe
			quest::faction(331, 3);		#:: + Merchants of Highpass
			quest::faction(230, 3);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 3);		#:: + The Freeport Militia
			#:: Grant a small amount of experience
			$client->AddLevelBasedExp(3, 16);
			#:: Create a hash for storing cash - 1500 to 1650cp
			my %cash = plugin::RandomCash(1500,1650);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Else eat the items
	}
	#:: Match two 13791 - Orc Scalp
	elsif (plugin::check_handin(\%itemcount, 13791 => 2)) {
		#:: Match if faction is Apprehensive or better
		if ($faction <= 6) {
			quest::say("Great work. Maybe you can help us out again sometime?");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(332, 4);		#:: + Highpass Guards
			quest::faction(329, 2);		#:: + Carson McCabe
			quest::faction(331, 2);		#:: + Merchants of Highpass
			quest::faction(230, 2);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 2);		#:: + The Freeport Militia
			#:: Grant a small amount of experience
			$client->AddLevelBasedExp(2, 16);
			#:: Create a hash for storing cash - 1000 to 1100cp
			my %cash = plugin::RandomCash(1000,1100);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Else eat the items
	}
	#:: Match a 13791 - Orc Scalp
	elsif (plugin::check_handin(\%itemcount, 13791 => 1)) {
		#:: Match if faction is Apprehensive or better
		if ($faction <= 6) {
			quest::say("Great work. Maybe you can help us out again sometime?");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(332, 2);		#:: + Highpass Guards
			quest::faction(329, 1);		#:: + Carson McCabe
			quest::faction(331, 1);		#:: + Merchants of Highpass
			quest::faction(230, 1);		#:: + Corrupt Qeynos Guards
			quest::faction(330, 1);		#:: + The Freeport Militia
			#:: Grant a small amount of experience
			$client->AddLevelBasedExp(1, 16);
			#:: Create a hash for storing cash - 500 to 550cp
			my %cash = plugin::RandomCash(500,550);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Else eat the items
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
