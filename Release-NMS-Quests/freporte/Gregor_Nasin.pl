sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Sit down and name your poison!  I know we are lacking in originality, but I intend to create some [exotic drinks].");
	}
	elsif ($text=~/exotic drinks/i) {
		quest::say("Interested in exotic drinks, are we?  I am attempting to create some of these drinks I read about in this book I found. It was called the [Barkeep's Compendium].  I will first need to get my hands on a few [exotic ingredients].");
	}
	elsif ($text=~/barkeep's compendium/i) {
		quest::say("I found the book amongst some garbage littering the ground in Freeport East.  It appears to have been created by an ogre named [Clurg].  I am sure he wants it returned, but I will never part with it.  That is... unless I get a few [exotic ingredients] I need to experiment with.");
	}
	elsif ($text=~/exotic ingredients/i) {
		quest::say("I desire a [kiola nut], [Erud's Tonic], [honey jum] and a [Koalindl fish].  If I could get those, I would no longer need to hold on to the [Barkeep's Compendium].  Whoever returned the ingredients to me could have it!!");
	}
	elsif ($text=~/kiola nut/i) {
		quest::say("The kiola nut usually grows only in humid territories.  I hear there are some such lands between Qeynos and Erudin.  Some also have been found on the islands of the Ocean of Tears.");
	}
	elsif ($text=~/erud's tonic/i) {
		quest::say("Now that is an ingredient that is hard to obtain.  Found only in the city of Erudin, it is a crime for anyone to attempt to smuggle it out of the city.  If caught, a horrid death is assured, though I hear there is a frequent customer of the taverns of Qeynos who has a way to obtain the forbidden liquid.");
	}
	elsif ($text=~/honey jum/i) {
		quest::say("Honey jum can be found in the halfling community of Rivervale.  I hear it is used in many of their potions.  I am sure it can be purchased somewhere in Rivervale.  If it is not on the shelf it is surely known by the shopkeeper.");
	}
	elsif ($text=~/koalindl fish/i) {
		quest::say("Some rare drinks call for ground up fish. I intend to use the Koalindl fish of Qeynos.  It is said to be magical in nature.  The problem with obtaining them is that you must get them from Jahnda's Pool near the Temple of Life and I hear that the members protect these fish with great ferocity.");
	}
	elsif ($text=~/clurg/i) {
		quest::say("I do not know. Ask an ogre. Maybe they have heard of him.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13118. 13382, 13952, 13340 -  Erud's Tonic - Koalindl Fish - Honey Jum - Kiola Nut
	if (plugin::check_handin(\%itemcount, 13118 => 1, 13383 => 1, 13952 => 1, 13340 => 1)) {
		quest::say("Now I have every ingredient mentioned in the Barkeep Compendium. Here. You take it. <..click!.> Whoops!! I just closed it. It's magically sealed, I never closed it before. It's useless to you. I have no need for it any longer. Maybe you can return it to [Clurg] for some type of reward.");
		#:: Give item 13379 - Barkeep Compendium
		quest::summonitem(13379);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(336, 5); 		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 5);	 		#:: + Coalition of Trade Folk
		quest::faction(329, 1); 		#:: + Carson McCabe
		quest::faction(230, 1); 		#:: + Corrupt Qeynos Guards
		quest::faction(330, 1); 		#:: + Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 1000 to 2000cp
		my %cash = plugin::RandomCash(1000,2000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
	#:: Match signal '1' from /freporte/Brunar_Rankin.pl
	if ($signal == 1) {
		quest::say("Thank you, Brunar. You are some kind of fisherman! I better take this down to the storeroom with your earlier catches before it spoils.. hmm.. a little later.");	
	}
}
