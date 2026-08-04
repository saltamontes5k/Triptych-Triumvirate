sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Good day to you $name I hope you yearn to become a Steel Warrior as we all are here in the Bunker. We are in need of more recruits to continue the [war].");
	}
	elsif ($text=~/war/i) {
		quest::say("The war I speak of is the one we Steel Warriors have sworn to wage agianst [Clan Deathfist] in the Commonlands. We are doing a fine job but we require more weapons. We are expecting a shipment of blades from Groflahs Forge. We require a warrior of the bunker to [get our shipment]. Maybe you?");
	}
	elsif ($text=~/clan deathfist/i) {
		quest::say("If you do not know of Clan Deathfist go ask Cain who they are. He will not only tell you he will sign you up to help fight our war!");
	}
	elsif ($text=~/shipment/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("We would be most thankful for your service. Please take this voucher over to Groflah at Groflahs Forge in North Freeport. He will give you the shipment of weapons.");
			#:: Give item 18820 - Sealed Letter
			quest::summonitem(18820);
		}
		else {
			quest::say("Only a warrior would be capable of this service, but thanks for offering.");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 12241 - Raw Short Sword 1, 12242 - Raw Short Sword 2, 12243 - Raw Short Sword 3, 12244 - Raw Short Sword 4
	if (plugin::check_handin(\%itemcount, 12241 => 1, 12242 => 1, 12243 => 1, 12244 => 1)) {
		quest::say("Good work, $name. The bunker shall be well stocked. Here you are, my friend. Take this raw blade. You can take it to Groflah - he will sharpen and polish it for you. It should be a formidable weapon.");
		#:: Give a 13919 - Reward Raw Short Sword
		quest::summonitem(13919);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(311, 20); 	#:: + Steel Warriors
		quest::faction(262, 4); 	#:: + Guards of Qeynos
		quest::faction(230, -3); 	#:: - Corrupt Qeynos Guards
		quest::faction(330, -3); 	#:: - The Freeport Militia
		quest::faction(281, 4); 	#:: + Knights of Truth
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 50 to 100cp
		my %cash = plugin::RandomCash(50,100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
#:: 	quest::say("This is only one sword. I requested four altogether. You shall not get your payment until I get my fourth sword");
}
