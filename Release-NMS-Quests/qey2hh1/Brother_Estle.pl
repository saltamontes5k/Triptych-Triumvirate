sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Prime Healer!! Guide me to victory!!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, child of life. The way of the [Prime Healer] shall set you free and cleanse your soul. I hope to see you at [mass].");
	}
	elsif ($text=~/prime healer/i) {
		quest::say("Rodcet Nife is the Prime Healer. His way is the path of healing and life. There can be no true life until your soul is healed by healing others. This will take you into the eternal when your time comes.");
	}
	elsif ($text=~/mass/i) {
		quest::say("Mass is not being held out here as yet. I am waiting for the [blessed oil] from the Temple of Life. You may attend services there.");
	}
	elsif ($text=~/blessed oil/i) {
		quest::say("The blessed oil is necessary during services. It is blessed by High Priestess Jahnda at the [Temple of Life]. If you are going in that direction, please stop at the temple and remind High Priestess Jahnda that brother Estle is waiting for his blessed oil.");
	}
	elsif ($text=~/temple of life/i) {
		quest::say("The Temple of Life is the center of worship for the followers of Rodcet Nife. It is located in North Qeynos and is one of the greatest temples ever created. Be sure to visit and attend services.");
	}
	elsif ($text=~/chintle/i) {
		quest::say("Brother Chintle is my fellow cleric from the Temple of Life. A few of us were sent to the plains to help out the residents.");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 1
	if ($wp == 1) {
		quest::say("I believe here is where I am to wait for the [blessed oil].");
	}
	#:: Match waypoint 2 or 5
	elsif (($wp == 2) || ($wp == 5)) {
		quest::say("Cleanse your souls, sinners! The way of life is found through the [Prime Healer]. Repent and join us!");
	}
}

sub EVENT_ITEM {
	#:: Match a 13910 - Blessed Oil Flask
	if (plugin::check_handin(\%itemcount, 13910 => 1)) {
		quest::say("Thank you. Now I may cleanse the bodies of the new converts and help them enter into a new life. I also have this. It was given to me by a dying gnoll of all things. They belong to Brother Hayle. The gnoll's last words were 'Free him.' Make sure High Priestess Jahnda gets this. Be swift!");
		#:: Give a 13911 - PrayerBeads
		quest::summonitem(13911);
		#:: Ding
		quest::ding();
		#:: Set factions
		quest::faction(341, 15);		#:: + Priests of Life
		quest::faction(280, 4);			#:: + Knights of Thunder
		quest::faction(262, 7);			#:: + Guards of Qeynos
		quest::faction(221, -3);		#:: - Bloodsabers
		quest::faction(219, 2);			#:: + Antonius Bayle
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 10 to 50cp
		my %cash = plugin::RandomCash(10,50);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Your name has been stricken from the book of the Prime Healer!! I shall be avenged!");
}
