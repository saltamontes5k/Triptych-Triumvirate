sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome back, $name. Why don't you purchase a few things before you head out into the tundra again?");
	}
	elsif ($text=~/baker/i) {
		quest::say("Great, you can help me restock. Help me restock my [muffins]? Or maybe bring us a [shipment of bread]."); 
	}
	elsif ($text=~/muffins/i) {
		quest::say("Take dis crate and fill it with hand crafted muffins.  They are much better than store bought."); 
		#:: Give a 17881 - Muffin Crate
		quest::summonitem(17881);
	}
	elsif ($text=~/shipment of bread/i) {
		quest::say("Far away in the Southern Plains of Karana a centaur named Meadowgreen makes the best bread. If you were to get some for us, it sure would help.");
	}
}

sub EVENT_ITEM {
	#:: Match a 1839 - Full Muffin Crate
	if (plugin::check_handin(\%itemcount, 1839 => 1)) {
		quest::say("Oh, yes, this is exactly what I needed. These muffins look very fresh too, good work! Here is your payment, as promised. It was a pleasure doing business with you.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 2); 	#:: + Merchants of Halas
		quest::faction(320, 1);		#:: + Wolves of the North
		quest::faction(327, 1);		#:: + Shamen of Justice
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
		#:: Create a hash for storing cash - 500 to 750cp
		my %cash = plugin::RandomCash(500,750);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Halas >> Hetie_McDonald (29038), restock 13014 - Muffin, quantity 20
		quest::MerchantSetItem(29038, 13014, 20);
	}
	#:: Match a 1838 - Bag of Bread Loaves
	elsif (plugin::check_handin(\%itemcount, 1838 => 1)) {
		quest::say("Fresh Bread!  Thank you!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 4); 	#:: + Merchants of Halas
		quest::faction(320, 1);		#:: + Wolves of the North
		quest::faction(327, 1);		#:: + Shamen of Justice
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
		#:: Create a hash for storing cash - 1200 to 1400cp
		my %cash = plugin::RandomCash(1200, 1400);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
