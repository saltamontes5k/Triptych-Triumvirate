sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome $name! This is the Temple of Marr and you must be another seeker of passion and valor. That is good. Become one with us and help us to defeat the [fallen knight]. It is he who has caused the demise of this city.");
	}
	elsif ($text=~/fallen knight/i) {
		quest::say("The fallen knight I speak of is none other than Sir Lucan D'Lere. The self proclaimed ruler of this city. He is no ruler and he never was no true Knight of Truth. If it were not for the [Crusade of Tears] this city would still be united in valor.");
	}
	elsif ($text=~/crusade of tears/i) {
		quest::say("In the year of thirty one hundred fifty, the Knights of Truth were called upon by the twin gods Erollisi and Mithaniel Marr. They instructed us to go forth across the Ocean of Tears and across the lands of Faydwer and purge the lands of the undead. It was during this crusade Freeport was left in the care of Sir Lucan D'Lere. How unfortunate.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18735 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18735 => 1 )) {
		quest::say("Welcome to the Priests of Marr. Here, you will be taught how powerful passion truly is. The passion of Erollisi Marr, the Queen of Love, shall flow through you and into all those you meet. Wear this tunic in the name of Love.");
		#:: Give a 13556 - White and Blue Tunic*
		quest::summonitem(13556);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 100);		#:: + Priests of Marr
		quest::faction(281, 15);		#:: + Knights of Truth
		quest::faction(330, -10);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_ITEM {
	#:: Match a 18736 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18736 => 1 )) {
		quest::say("Welcome to the Priests of Marr. Here, you will be taught how powerful passion truly is. The passion of Erollisi Marr, the Queen of Love, shall flow through you and into all those you meet. Wear this tunic in the name of Love.");
		#:: Give a 13556 - White and Blue Tunic*
		quest::summonitem(13556);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 100);		#:: + Priests of Marr
		quest::faction(281, 15);		#:: + Knights of Truth
		quest::faction(330, -10);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
