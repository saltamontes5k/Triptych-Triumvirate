sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to the shrine of the Dismal Rage.  May [Innoruuk] guide your every move in life.  Here. we will teach you to release your rage unto the world.  My priests are at your disposal.");
	}
	elsif ($text=~/innoruuk/i) {
		quest::say("You do not even know the name of the Prince of Hate! That is a crime in here. Our god Innoruuk speaks with Pietro Zarn himself. It was Innoruuk who told him to create the Dismal Rage. You should speak with our family. Perhaps someone will help you better understand our beliefs.");
	}
	elsif ($text=~/pietro zarn/i) {
		quest::say("Pietro Zarn is our great leader. It was he who Innoruuk spoke to and guided him to form the Dismal Rage. It was he who saved Opal, Xicotl and I from lives wasted. I am the Priest of Hate and Opal commands the black arts. Xicotl was the might. A troll brute of unbelievable strength. Together we created this shrine.");
	}
	elsif ($text=~/bayle list/i) {
		quest::say("Oh. You must be the shadowknight who shall return the list to [Pietro Zarn]. The Bayle List is actually three scrolls with coded words. Alone they are nonsense. Together they can be coded and tell something of value. Antonius Bayle had them created and gave them to three of his most trusted friends. Of these I know, Lady Shae his old love. Then there is Captain Linarius Grafe, captain of the outer Qeynos Guards. Lastly there is Frenway Marthank, Antonius Bayle's oldest friend. He is a resident of the Jaggedpine. When you recover the scrolls you must take them to Rathmana Allin. He is a master scribe. He will decode the scrolls for us. He can be found in deserts of South Ro. Now you best be off, before some other finds the scrolls. You must get there first and return the decoded list to Pietro Zarn.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18744 -  A tattered note
	if (plugin::check_handin(\%itemcount, 18744 => 1)) {
		quest::say("Here we find a new follower.. Here we find a tunic of the Dismal Rage. Put the two together and let the hate grow. Let it be known from now on that your soul belongs to the Prince of Hate, Innoruuk. It is his power which flows within you. Destroy all those who oppose us. Please introduce your hate to the others in this shrine.");
		#:: Give item 13561 - Faded Crimson Tunic
		quest::summonitem(13561);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 	#:: + Dismal Rage
		quest::faction(281, -15); 	#:: - Knights of Truth
		quest::faction(296, 20); 	#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
