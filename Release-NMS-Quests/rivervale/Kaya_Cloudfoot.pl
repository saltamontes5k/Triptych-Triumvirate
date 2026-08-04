sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18431 - Halfling Paladin Note
	if (plugin::check_hasitem($client, 18431)) { 
		$client->Message(15,"A tiny voice calls your name. 'Welcome $name. I knew you would make it. I am Kaya Cloudfoot, Guild Master for the Paladins of the Storm Reapers. Read the note in your inventory and hand it to me when you are ready to begin your training. May the Rainlord bless you on your new path in life.'");
	}
}

sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("A pleasure to make your acquaintance $name. I am Kaya Cloudfoot, first Paladin of the Storm Reapers. I traveled long ago when I was just a wee sprout to the city of Qeynos far to the West. It was there I grew under the tutelage of the Knights of Thunder, a noble order of paladins loyal to Karana, the Storm Lord. I have returned now to Rivervale to teach interested young halflings the ways of a Knight of the Storm Reapers so that we may defend Karanas people and lands from the [evil forces] that would see it destroyed.");
	}
	elsif ($text=~/evil forces/i) {
		quest::say("There are many problems and creatures that trouble Karanas people throughout Norrath and threaten our otherwise peaceful ways of life. Our common folk here in Rivervale are troubled by the wicked Teir`Dal, the Death Fist Orcs, and the Goblins of Clan Runnyeye and Pickclaw. It is the calling and duty of a Knight of the Storm Reapers to defend the common folk from these enemies of Rivervale.");
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
	#:: Match a 18431 - Halfling Paladin Note
	if (plugin::check_handin(\%itemcount, 18431 => 1)) {
		quest::say("Karana smiles upon you young $name! Take this tunic to keep you warm through the storms you must face. There is evil encroaching upon the lands of Karana's faithful. The wicked minions of Bertoxxulous and the Teir'Dal children of Hate corrupt the lands to the west and east, and the Deathfist Clan of Orcs are waging war on this region while destoying the wilderness for lumber and stone. It is Karana's will that we defend our lands and way of life from these evil threats. When you are ready to begin adventuring, I will be happy to advise you on how to help us deal with the [evil forces]. I also posses knowledge of various [trades], seek me out when you wish to learn about them.");
		#:: Give a 13541 - Jumjum Sack Tunic*
		quest::summonitem(13541);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(355, 100); 	#:: + Storm Reapers
		quest::faction(286, 10);	#:: + Mayor Gubbin
		quest::faction(292, 15);	#:: + Merchants of Rivervale
		quest::faction(324, -15);	#:: - Unkempt Druids
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
