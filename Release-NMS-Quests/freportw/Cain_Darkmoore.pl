sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name! We are the Steel Warriors of Freeport. Our training disciplines have created some of the finest warriors ever to walk upon Norrath. Perhaps the bards shall sing songs of you one day. Let your first mission be the extermination of [Clan Deathfist].");
	}
	elsif ($text=~/clan deathfist/i) {
		quest::say("The orcs of the Commonlands call themselves Clan Deathfist. They have committed many vile acts upon the residents of the Commonlands as well as persons traveling to and from Freeport. They must be destroyed. Go forth to slay them. I shall pay a bounty for every two Deathfist belts. If you are a true warrior of the bunker then perhaps you can begin with [The Green and Blue].");
	}
	elsif ($text=~/green and blue/i) {
		quest::say("The Green and Blue was a test for all skilled warriors. All one needed do was return to me four orc legionnaire shoulderpads. Two from the loathsome green skinned Deathfist Clan and two from the vile blue skinned Crushbone Clan. But we have no more bunker battle blades to spare. We must prepare for war!!");
	}
	elsif ($text=~/bigger problem/i) {
		quest::say("The bigger problem is the Freeport Militia. Go to the Hall of Truth and speak with the Knights of Truth about that. They have already started their campaign to rid the city of the militia. The so-called Freeport Militia is not to be trusted.");
	}
	elsif ($text=~/opal/i) {
		quest::say("Opal. Beautiful Opal Darkbriar. Never before have I gazed upon a more beautiful creature. She works as a librarian at the Academy of Arcane Science. Someday she shall be mine. A warrior as bold as myself deserves the very best and she is truly that.");
	}
	elsif ($text=~/bunker blade|bunker battle blade/i) {
		quest::say("The bunker battle blade was crafted and enchanted for use by warriors only. It has the power to strike down those creatures which hide behind their magic. Once bestowed upon a warrior, it cannot leave your side or it shall vanish from this realm forever. One must perform the [green and blue] to earn such a blade.");
	}
}

sub EVENT_ITEM {
	#:: Match two 13916 - Deathfist Slashed Belt
	if (plugin::check_handin(\%itemcount, 13916 => 2 )) {
		quest::say("Very fine work $name. With your help, we shall soon rid the commonlands of the orcs. Then we can move on to a [bigger problem].");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, -1); 			#:: - Freeport Militia
		quest::faction(230, -1); 			#:: - Corrupt Qeynos Guards
		quest::faction(311, 1); 			#:: + Steel Warriors
		quest::faction(281, 1); 			#:: + Knights of Truth
		quest::faction(262, 1); 			#:: + Guards of Qeynos
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 100 to 800cp
		my %cash = plugin::RandomCash(100,800);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match one 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 1 )) {
		quest::say("I must have two Deathfist belts.");
		#:: Return a 13916 - Deathfist Slashed Belt
		quest::summonitem(13916);
	}
	#:: Match a 18742 - A Tattered Note
	elsif (plugin::check_handin(\%itemcount, 18742 => 1 )) {
		quest::say("Welcome to the Steel Warriors, young warrior. It is time to prove your mettle. Look to the outskirts of Freeport and join the fray. Show Clan Deathfist what a warrior of the bunker can do.");
		#:: Give item 13572 - Dirty Training Tunic
		quest::summonitem(13572);		
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, -15); 			#:: - Freeport Militia
		quest::faction(311, 100); 			#:: + Steel Warriors
		quest::faction(230, -15); 			#:: - Corrupt Qeynos Guards
		quest::faction(262, 20); 			#:: + Guards of Qeynos
		quest::faction(281, 1); 			#:: + Knights of Truth
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13319 - Crushbone Shoulderpads x2 and 13917 Deathfist Shoulderpads x2
	elsif (plugin::check_handin(\%itemcount, 13319 => 2, 13917 => 2)) {
		quest::say("Very fine work, $name. With your help, we shall soon rid the commonlands of the orcs. Then we can move on to a [bigger problem]");
		#:: Give item 5369 - Bunker Battle Blade
		quest::summonitem(15369);		
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(330, -15); 			#:: - Freeport Militia
		quest::faction(311, 100); 			#:: + Steel Warriors
		quest::faction(230, -15); 			#:: - Corrupt Qeynos Guards
		quest::faction(262, 20); 			#:: + Guards of Qeynos
		quest::faction(281, 10); 			#:: + Knights of Truth
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
