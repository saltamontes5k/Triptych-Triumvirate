sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Welcome! Why don't you browse through my selection of fine goods and pick out some things you like $name?");
	}
	elsif ($text=~/baker/i) {
		quest::say("You are a baker?  I could use a new supply of [muffins]. Or maybe you would travel to South Karana for a [shipment of bread]?");
	}
	elsif ($text=~/muffins/i) {
		quest::say("Take this crate and fill it with fresh baked muffins.");
		#:: Give a 17881 - Muffin Crate
		quest::summonitem(17881);
	}
	elsif ($text=~/shipment of bread/i) {
		quest::say("Ok, find the centaur named Meadowgreen.  His bread is the best I have tasted.");
	}
}

sub EVENT_ITEM {
	#:: Match 1839 - Full Muffin Crate
	if (plugin::check_handin(\%itemcount, 1839 => 1)) {
		quest::say("These are quality muffins! You are obviously quite a skilled baker. Here is your payment as promised. Now I can get back to business again.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 2);			#:: + Coalition of Tradefolk
		quest::faction(281, 2);			#:: + Knights of Truth
		quest::faction(291, 1);			#:: + Merchants of Qeynos
		quest::faction(336, 2);			#:: + Coalition of Tradefolk Underground
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
		#:: Create a hash for storing cash - 500 to 750cp
		my %cash = plugin::RandomCash(500, 750);
		#:: Grant a random cash reward
		quest::givecash($cash{copper}, $cash{silver}, $cash{gold}, $cash{platinum});
		#:: North Freeport >> Gern Tessel (8014), restock 13014 - Muffin, quantity 20
		quest::MerchantSetItem(8014, 13014, 20);
	}
	#:: Match a 1838 - Bag of Bread Loaves
	elsif (plugin::check_handin(\%itemcount, 1838 => 1)) {
		quest::say("Thanks for the bread!!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 4);			#:: + Coalition of Tradefolk
		quest::faction(281, 4);			#:: + Knights of Truth
		quest::faction(291, 1);			#:: + Merchants of Qeynos
		quest::faction(336, 4);			#:: + Coalition of Tradefolk Underground
		#:: Create a hash for storing cash - 1300 to 2200cp
		my %cash = plugin::RandomCash(1300, 2200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper}, $cash{silver}, $cash{gold}, $cash{platinum});
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
