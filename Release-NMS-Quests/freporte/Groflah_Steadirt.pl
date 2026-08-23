sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name! Join in the [celebration]! Have a few drinks. Alas, there are no [Tumpy Tonics].");
	}
	elsif ($text=~/celebration/i) {
		quest::say("The Freeport Militia now has a bar to themselves. Luckily, it is not this one. Ahh... I tell you, I just don't feel up to much right now. I have had so much grog, my great grandma could best me!");
	}
	elsif ($text=~/ariska/i) {
		quest::say("Ariska Zimel was my best friend. He and I learned our knowledge of metal from such places as Halas and Kaladim. When he disappeared, it seemed to involve foul play. He must be alive somewhere in the city. I pray this is not the work of [Pietro Zarn].");
	}
	elsif ($text=~/pietro zarn/i) {
		quest::say("While we were traveling through the Lavastorm Mountains, we happened upon a caravan. They wore emblems in honor of the evil god, Innoruuk. They did not see us, but we saw them. And most importantly of all, Ariska saw the apparent leader's sword. It was glowing with great energy. Suddenly, the evil knights were in a battle. The knights gave chase, leaving their camp unattended. The knight who owned the sword left it behind, opting to fight with another, leading me to believe it was not his to begin with. It was at this point that Ariska ran down and grabbed the sword. A few weeks later, we were to learn that the knight was a powerful man by the name of Pietro Zarn and that he was looking for a sword stolen from him. He called it .. Soulfire. I believe Zarn must have finally found Ariska.");
	}
	elsif ($text=~/tumpy tonics/i) {
		quest::say("Tumpy Tonics are great!! I used to drink them often in a bar in Kaladim. Kind of glad they don't serve it here. I could not stop drinking them and they would always cause me to drain the dragon. I get tired of running to the docks for that reason.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18818 - Tattered Flier
	if (plugin::check_handin(\%itemcount, 18818 => 1)) {
		quest::say("This used to be hanging in Zimel's Blades. It is the price list. It is badly faded though. There was a fire in Zimel's Blades and I was on the scene just afterward. I did not see this hanging. I wonder who took it . . . Hmmmm.. oh, yes.. the markings on the list! It is a code! Here. I will fill it in. Read it. You probably do not even know who [Ariska] is.");
		#:: Give item 18819 - Tattered Flier
		quest::summonitem(18819);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 1); 		#:: + Coalition of Trade Folk
		quest::faction(336, 1); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, 1); 		#:: + Knights of Truth
		quest::faction(291, 1); 		#:: + Merchants of Qeynos
		#:: Grant a small amount of experience
		quest::exp(15);
	}
	#:: Match four 12114 - Trumpy Tonic
	elsif (plugin::check_handin(\%itemcount, 12114 => 4)) {
		quest::say("Ahh! I missed those. I was just telling myself the other... Uh oh! I have to use the little dwarf's facilities. Excuse me.' ");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 40); 		#:: + Coalition of Trade Folk
		quest::faction(336, 40); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, 40); 		#:: + Knights of Truth
		quest::faction(291, 28); 		#:: + Merchants of Qeynos
		#:: Grant a small amount of experience
		quest::exp(60);
		#:: Create a hash for storing cash - 200 to 400cp
		my %cash = plugin::RandomCash(200,400);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match three 12114 - Trumpy Tonic
	elsif (plugin::check_handin(\%itemcount, 12114 => 3)) {
		quest::say("Ahh! I missed those. I was just telling myself the other... Uh oh! I have to use the little dwarf's facilities. Excuse me.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 30); 		#:: + Coalition of Trade Folk
		quest::faction(336, 30); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, 30); 		#:: + Knights of Truth
		quest::faction(291, 21); 		#:: + Merchants of Qeynos
		#:: Grant a small amount of experience
		quest::exp(45);
		#:: Create a hash for storing cash - 100 to 300cp
		my %cash = plugin::RandomCash(100,300);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});	
	}	
	#:: Match two 12114 - Trumpy Tonic
	elsif (plugin::check_handin(\%itemcount, 12114 => 2)) {
		quest::say("Ahh! I missed those. I was just telling myself the other... Uh oh! I have to use the little dwarf's facilities. Excuse me. ");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 20); 		#:: + Coalition of Trade Folk
		quest::faction(336, 20); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, 20); 		#:: + Knights of Truth
		quest::faction(291, 14); 		#:: + Merchants of Qeynos
		#:: Grant a small amount of experience
		quest::exp(30);
		#:: Create a hash for storing cash - 50 to 200cp
		my %cash = plugin::RandomCash(50,200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});	
	}	
	#:: Match a 12114 - Trumpy Tonic
	elsif (plugin::check_handin(\%itemcount, 12114 => 1)) {
		quest::say("Ahh! I missed those. I was just telling myself the other... Uh oh! I have to use the little dwarf's facilities. Excuse me.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 10); 		#:: + Coalition of Trade Folk
		quest::faction(336, 10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281, 10); 		#:: + Knights of Truth
		quest::faction(291, 7); 		#:: + Merchants of Qeynos
		#:: Grant a small amount of experience
		quest::exp(15);
		#:: Create a hash for storing cash - 1 to 100cp
		my %cash = plugin::RandomCash(1,100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("The good people of this city will know of this. They will strike back at you!");
}
