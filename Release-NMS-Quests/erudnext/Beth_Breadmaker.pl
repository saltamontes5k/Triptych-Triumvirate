sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Hi $name. Times are tough these days. I am finding myself running short on baked goods lately. Would you be [willing to help] me out?"); 
	}
	elsif ($text=~/willing to help/i) {
		quest::say("You'd help me? Oh, you are such a dear! Well, there are two ways you can help me and my little business. If you [can bake] you can make me some muffins so I don't run out. Otherwise, you [can travel] a little way for me and pick up some bread.");
	}
	elsif ($text=~/can bake/i) {
		quest::say("You can bake, that's wonderful. Take this crate and fill it with muffins, then seal it up and bring it back to me. Don't go trying to pass off that store bought stuff, I need fresh baked muffins. The ones in the stores are already too old and will get moldy too fast, so I don't want those.");
		#:: Give a 17881 - Muffin Crate
		quest::summonitem(17881);
	}
	elsif ($text=~/can travel/i) {
		quest::say("There is a wonderful baker that lives in the southern plains. I guess the plague hasn't hit that area too bad. Anyway, he's one heck of a baker and makes some quality bread. Go look him up and tell him you want a bag of bread loaves. He's one of those fellas that goes by the name of Meadowgreen.");
	}
}

sub EVENT_ITEM {
	#:: Match a 1839 - Full Muffin Crate
	if (plugin::check_handin(\%itemcount, 1839 => 1)) {
		quest::say("Thanks, you are a dear. You are one top notch baker!  Here's some coin for your trouble.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(289, 2);		#:: + Merchants of Erudin
		quest::faction(266, 1);		#:: + High Guard of Erudin
		quest::faction(267, 1);		#:: + High Council of Erudin
		#:: Add 13014 - Muffin x20 to Erudin >> Beth_Breadmaker (24059)
		quest::MerchantSetItem(24059, 13014, 20);
		#:: Create a hash for storing cash - 200 to 300cp
		my %cash = plugin::RandomCash(200, 300);
		#:: Grant a random cash reward
		quest::givecash($cash{copper}, $cash{silver}, $cash{gold}, $cash{platinum});
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
	}
	#:: Match a 1838 - Bag of Bread Loaves
	elsif (plugin::check_handin(\%itemcount, 1838 => 1)) {
		quest::say("Oh, wonderful fresh bread! Thank you for making the trip, that is such a long way. Here, I hope this covers your travel expenses. You have my deepest thanks.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(289, 4);		#:: + Merchants of Erudin
		quest::faction(266, 1);		#:: + High Guard of Erudin
		quest::faction(267, 1);		#:: + High Council of Erudin
		#:: Create a hash for storing cash - 1600 to 1800cp
		my %cash = plugin::RandomCash(1600, 1800);
		#:: Grant a random cash reward
		quest::givecash($cash{copper}, $cash{silver}, $cash{gold}, $cash{platinum});
		#:: Grant a small amount of level-based experience
		$client->AddLevelBasedExp(4, 14);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}