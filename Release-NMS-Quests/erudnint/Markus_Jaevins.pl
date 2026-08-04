sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Check for 18728 - Tattered Note
	if (plugin::check_hasitem($client, 18728)) {
		$client->Message(15,"Markus Jaevins tells you, 'Welcome to the Tower of the Gate Callers, I am Markus Jaevins. Please read the note in your inventory and hand it to me when you are ready to start learning the ways of the Magician.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings young one. It is always good to see a new face here in the Palace of Erudin, the perfect city state, free from [crime].");
	}
	elsif ($text=~/crime/i) {
		quest::say("Oh, yes. We here in Erudin have no crime. Actually, it is a very low crime rate. Most of those crimes are committed by the defective brains of [heretics] or inferior, non-Erudite races.");
	}
	elsif ($text=~/heretics/i) {
		quest::say("The heretics are our sworn enemies. Their ancient origins are our own, however, they are the mad Erudites who chose the dark side of magic called necromancy. We, the magicians, caught one snooping in the palace just last week. He is now our [prisoner].");
	}
	elsif ($text=~/prisoner/i) {
		quest::say("The infidel was memorizing our spells to take to the rest of the heretic scum. He will finally be [purged] today. Could you please go to the cells here in the palace and ask  [Jail Master Lius] to give you the heretic's remains?");
	}
	elsif ($text=~/purged/i) {
		quest::say("To be purged is to take all the evil from ones body and set your soul free. Through magical means, the Erudite Cleansers pull the accused's organs out through the mouth. When all is done, you can be assured the body is cleansed of all evil.");
	}
	elsif ($text=~/jail master lius/i) {
		quest::say("The prison is on the lower level of the palace inside the City Office.");
	}
	elsif ($text=~/heretic has escaped/i) {
		quest::say("Escaped!! This is not good. The sentinels will not find him in time. You must find him. When you find him, release his soul and rid his body of evil any way you can. Bring me proof and all will be well.");
	}
}

sub EVENT_ITEM {
	#:: Match turn in for 18728 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18728 => 1)) {
		quest::say("Welcome. young one! I see you show interest in the circle of magic. Nowhere upon Norrath will you find a greater school than this - the Gatecallers. You shall wear this tunic as a sign that you have begun the training of this circle. Remember, the power of the Gatecaller is the power of summoning. Go find Vasile, he will help teach you the basics of summoning. Good luck, friend!");
		#:: Give item 13548 - Old Torn Robe*
		quest::summonitem(13548);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(254, 100);	#:: + Gate Callers
		quest::faction(267, 15);	#:: + High Guard of Erudin
		quest::faction(266, 10);	#:: + High Council of Erudin
		quest::faction(265, -15);	#:: - Heretics
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match turn in for 13128 - Bones
	elsif (plugin::check_handin(\%itemcount, 13128 => 1)) {
		quest::say("This is fine work, young one. You keep this up and you shall be knighted before long.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(254, 50);	#:: + Gate Callers
		quest::faction(267, 7);		#:: + High Guard of Erudin
		quest::faction(266, 5);		#:: + High Council of Erudin
		quest::faction(265, -7);	#:: - Heretics
		#:: Grant a moderate amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 5 to 50cp
		my %cash = plugin::RandomCash(5,50);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match turn in for 13127 - Bones
	elsif (plugin::check_handin(\%itemcount, 13127 => 1)) {
		quest::say("This is fine work, young one. You keep this up and you shall be knighted before long.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(254, 25);	#:: + Gate Callers
		quest::faction(267, 3);		#:: + High Guard of Erudin
		quest::faction(266, 2);		#:: + High Council of Erudin
		quest::faction(265, -3);	#:: - Heretics
		#:: Grant a moderate amount of experience
		quest::exp(2500);
		#:: Create a hash for storing cash - 5 to 50cp
		my %cash = plugin::RandomCash(5,50);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
