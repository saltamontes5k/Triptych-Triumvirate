sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Check for 18432 - Halfling Ranger Note
	if (plugin::check_hasitem($client, 18432)) {
		$client->Message(15,"The fragrent smell of jumjum growing in the nearby field greets your nostrils. As you take in the wonderful fragrance, an important looking Halfling greets you. 'Welcome to the Tagglefoot's Farmstead. I am Megosh Thistlethorn. I can see by the gleam in your eyes that you are here to begin your training with the Storm Reapers. Read the note in your inventory and then hand it to me when you are ready to begin your training.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings $name! I am Megosh Thistlethorn first Ranger of the Storm Reapers of Rivervale. I journeyed many years ago to the Surefall Glade far to the west of our lovely shire. It was there I trained with the human and half-elven rangers that like the Storm Reapers are faithful disciples of Karana. I have returned now to Rivervale to teach our interested young people the ways of a ranger of the Storm Lord, so that we may defend our shire and the wilds of Norrath from the evil forces that would see it destroyed.");
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give a 51121 - Tradeskill Basics : Volume I
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give a 51122 - Tradeskill Basics : Volume II
		quest::summonitem(51122);
	}
}

sub EVENT_ITEM {
	#:: Match a 18432 - Halfling Ranger Note
	if (plugin::check_handin(\%itemcount, 18432 => 1)) {
		quest::say("Welcome to the Storm Reapers $name! Here is a tunic to keep you warm in your travels. Rivervale, our lovely home is facing dangerous times. From both the east and west forces devoted to the evil Gods Bertoxxulous adn Innoruuk are corrupting and destroying the wilds of Norrath. Also, the Orcs of Clan Deathfist are waging war on this entire region and gathering lumber and stone for some unknown purpose. We must do our best to preserve the lands and way of life of all Karanas people. Once you are ready to begin defending the vale against the evil forces, please return to me. I also posses knowledge of various [trades], seek me out when you wish to learn about them.");
		#:: Give a 13541 - Jumjum Sack Tunic*
		quest::summonitem(13541);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(355, 100);		#:: + Storm Reapers
		quest::faction(286, 10);		#:: + Mayor Gubbin
		quest::faction(292, 15);		#:: + Merchants of Rivervale
		quest::faction(324, -15);		#:: - Unkempt Druids
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
