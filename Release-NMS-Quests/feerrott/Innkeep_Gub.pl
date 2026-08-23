sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Huh? Oh hi $name. Youse want to buy sumthin?  Or maybe youz a [baker]?");
	}
	elsif ($text=~/baker/i) {
		quest::say("Gud, you help me restock. You helps me out by restocking my [muffinz]. Or you go findz da guy wid da gud bread loaves and bring mez a [shipment of bread].");
	}
	elsif ($text=~/muffin/i) {
		quest::say("You take dis crate and fill it with muffinz, den seal it up and bring da full crate bak to me. Don't you tink you can go buy dat store stuff either, I wants fresh baked muffinz.  Da store ones too old and will gets moldy too fast, den I have to toss out.  Da make me very unhappy wid you!");
		#:: Give a 17881 - Muffin Crate
		quest::summonitem(17881);
	}
	elsif ($text=~/shipment of bread/i) {
		quest::say("You go to da south plains and find da Meadowgreen guy.  He is very gud baker and we wantz his bag of bread loaves.  You go tell him dat, get movin!");
	}
}

sub EVENT_ITEM {
	#:: Match a 1839 - Full Muffin Crate
	if (plugin::check_handin(\%itemcount, 1839 => 1)) {
		quest::say("MMmmm... Deez look like gud muffins. Here's sum money. Tanks. Now meez all stocked again.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(338, 2);		#:: + Merchants of Oggok
		quest::faction(228, 1);		#:: + Clurg
		quest::faction(337, 1);		#:: + Oggok Guards
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
		#:: Create a hash for storing cash - 500 to 750cp
		my %cash = plugin::RandomCash(500,750);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Feerrott >> Innkeep Gub (47114), restock 13014 - Muffin, quantity 20
		quest::MerchantSetItem(47114, 13014, 20);
	}
	#:: Match a 1838 - Bag of Bread Loaves
	elsif (plugin::check_handin(\%itemcount, 1838 => 1)) {
		quest::say("You take some money. Weeze happy now dat weeze got more bread for sale. You maybe check back later if weeze run out of bread again.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(338, 4);		#:: + Merchants of Oggok
		quest::faction(228, 1);		#:: + Clurg
		quest::faction(337, 1);		#:: + Oggok Guards
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
