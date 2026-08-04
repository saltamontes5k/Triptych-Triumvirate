sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Huh? Oh hi. Weeze got a [problem] here. It not gud."); 
	}
	elsif ($text=~/problem/i) {
		quest::say("Da problem is dat weeze running low on sum kinds of foods. Weeze low on [muffins] and weeze also low on [loaves of bread]. Tink you can help us?"); 
	}
	elsif ($text=~/muffins/i) {
		quest::say("You take dis crate and fill it with muffinz, den seal it up and bring da full crate bak to me. Don't you tink you can go buy dat store stuff either, I wants fresh baked muffinz.  Da store ones too old and will gets moldy too fast, den I have to toss out.  Da make me very unhappy wid you!"); 
		#:: Give a 17881 - Muffin Crate
		quest::summonitem(17881);
	}
	elsif ($text=~/loaves of bread/i) {
		quest::say("You go to Plains of Karana. You look for Jarlen Meadowgreen. You tells him dat you there to get Bread Loaves for us. Weeze pay you when you get back. Tanks."); 
	}
}

sub EVENT_ITEM {
	#:: Match a 1839 - Full Muffin Crate
	if (plugin::check_handin(\%itemcount, 1839 => 1)) {
		quest::say("Nice muffins, very stinky. Weeze tank you. Here some money. Weeze need more muffins later. You check back again sum time.");
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
		#:: Feerrott >> Innkeep Morpa (47145), restock 13014 - Muffin, quantity 20
		quest::MerchantSetItem(47145, 13014, 20);
	}
	#:: Match a 1838 - Bag of Bread Loaves
	elsif (plugin::check_handin(\%itemcount, 1838 => 1)) {
		quest::say("You nice for getting bread loaves for us. You take some money. Weeze happy now dat weeze got more bread for sale. You maybe check back later if weeze run out of bread again");
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
