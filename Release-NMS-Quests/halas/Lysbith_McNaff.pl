sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail! Ye've come to [serve Halas] have ye not? We're the Wolves o' the North and it is our task to defend our city from harm.");
	}
	elsif ($text=~/serve Halas/i) {
		quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do to earn our trust. Perhaps ye should inquire o' the [gnoll bounty].");
	}
	elsif ($text=~/gnoll bounty/i) {
		quest::say("I've placed a bounty on the gnolls o' Blackburrow. Their whelps have invaded our land and we must carry the fight into their dens. Join the fight and return three gnoll fangs as proof of yer victory in Blackburrow. Do so, and earn the respect o' the Wolves o' the North.");
	}
	elsif ($text=~/orc troopers/i) {
		quest::say("So. Ye think yerself strong enough to battle the snow orc troopers?  I pray to the Tribunal that ye are.  If ye can return to me four wrath orc wristbands  from the troopers' bodies. I'll reward ye with the [Seax].");
	}
	elsif ($text=~/Seax/i) {
		quest::say("The Seax is a Northman warrior's piercing weapon.  Dinnae confuse this with another [weapon] related to the Seax called the Langseax.  The local rogues have also learned to master the Seax.  I'll only offer it to those who battle the [orc troopers].");
	}
	elsif ($text=~/ice goblins/i) {
		quest::say("The ice goblins have plagued our community fer some time now. At times, they even manage to get inside our walls. Fer the most part, they prey on travelers who pass through Everfrost Peaks. Since they're a weak race, we employ our youngest warriors to [protect the pass].");
	}
	elsif ($text=~/protect the pass/i) {
		quest::say("Then travel to the Everfrost Peaks and take this pack with ye. I want ye to return this pack to me when it is filled with the beaded ice necklaces o' the ice goblins. When it is filled, combine the items and return it to me and I'll decide whether ye deserve a reward fer yer deed.");
		#:: Give a 17944 - Empty Bag (*Bag for Ice Necklaces) 
		quest::summonitem(17944);
	}
}	
	
sub EVENT_ITEM {
	#:: Match three 13915 - Gnoll Fang
	if (plugin::check_handin(\%itemcount, 13915 => 3)) {
		quest::say("Fine work, fine work!  The gnoll threat must be extinguished before it can ever fully grow.  Ye've done yer part to aid our cause.  Please allow me to repay ye with a few provisions and a wee bit o' coin.  Then, continue with yer good deeds. Halas is surrounded by barren arctic tundra. We've many foes. Among them are the [orc troopers], [ice goblins] and the ever-present polar bears.");
		#:: Choose a random reward from 13005 - Iron Ration, 13007 - Ration, 13002 - Torch, 13006 - Water Flask
		quest::summonitem(quest::ChooseRandom(13005, 13007, 13002, 13006));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(320, 15);		#:: + Wolves of the North
		quest::faction(327, 3);			#:: + Shamen of Justice
		quest::faction(328, 3); 		#:: + Merchants of Halas
		quest::faction(311, 1);			#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 400 to 600cp
		my %cash = plugin::RandomCash(400,600);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match four 12223 - Wrath Orc Wristbands
	elsif (plugin::check_handin(\%itemcount, 12223 => 4)) {
		quest::say("Ye're becoming a fine champion o' Halas. Take th' Seax. May ye always defend Halas!");
		#:: Give a 7322 - Seax
		quest::summonitem(17322);
		#:: Ding!
		quest::ding();
		#:: Set Factions
		quest::faction(320, 20);		#:: + Wolves of the North
		quest::faction(327, 4);			#:: + Shamen of Justice
		quest::faction(328, 5); 		#:: + Merchants of Halas
		quest::faction(311, 1);			#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(800);
	}
	#:: Match a 13898 - Bag of Ice Necklaces
	elsif (plugin::check_handin(\%itemcount, 13898 => 1)) {
		quest::say("Ye've done well, me young $class.  We've gathered these to add to yer provisions.  While in the Everfrost Peaks, be on the watch fer any gnolls ye may find.  I declare there to be a [gnoll bounty].");
		#:: Choose a random reward from 13005 - Iron Ration, 13007 - Ration, 13002 - Torch, 13006 - Water Flask, 13003 - Small Lantern
		quest::summonitem(quest::ChooseRandom(13005, 13007, 13002, 13006, 13003));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(320, 10);		#:: + Wolves of the North
		quest::faction(327, 2);			#:: + Shamen of Justice
		quest::faction(328, 2); 		#:: + Merchants of Halas
		quest::faction(311, 1);			#:: + Steel Warriors
		#:: Grant a small amount of experience based on level
		$client->AddLevelBasedExp(15,3);
		#:: Create a hash for storing cash - 250 to 400cp
		my %cash = plugin::RandomCash(250,400);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}	
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
