sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Aagggh..  Get away from here..  Go, run..  Far away..  Or I shall call [Karana's] wrath upon you!");
	}
	elsif ($text=~/karana/i) {
		quest::say("Heh!..  Ignorant one!  Begone, and take your stupidity with you!");
	}
	elsif ($text=~/rat/i) {
		quest::say("Hey! Stop it.. you're making me hungry! Boy, I wish I had some fresh rat ears right now! Mmm..mmm..mmm!");
	}
}

sub EVENT_ITEM {
	#:: Match a 13072 - Rat Ears
	if (plugin::check_handin(\%itemcount, 13072 => 1)) {
		quest::say("Ahh yes..  These are a little small, but still some good eating, if you know how to cook 'em of course..   Here ya go, enjoy and may Karana keep your fields lush and green.");
		#:: Give a 13719 - Grilled Rat Ears
		quest::summonitem(13719);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 5);			#:: + Arcane Scientists
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(296, -1);		#:: - Opal Darkbriar
		quest::faction(330, -1);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Match a 13719 - Grilled Rat Ears
	elsif (plugin::check_handin(\%itemcount, 13719 => 1)) {
		quest::say("Wha?..   Ah, I guess it's a bit of an acquired taste..  Oh well, your loss..  Here, take this..  They ain't no ears, but it's the least I could do..   And if ya find any more rat ears, good ol' Rephas here will be glad to take 'em off your hands for ya!");
		#:: Give a 13076 - Fish Scales
		quest::summonitem(13076);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 5);			#:: + Arcane Scientists
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(296, -1);		#:: - Opal Darkbriar
		quest::faction(330, -1);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Match three 13050 - Giant Rat Ear
	elsif (plugin::check_handin(\%itemcount, 13050 => 3)) {
		quest::say("Wow!..  How big was the dang varmint that these come off of?!  Bigger'n a ol' grizzly, I bet!  You've earned this, my friend!  It's my own secret recipe for rat ear pie..  sure is tasty, easy to make, and keeps your belly full while you're running about in the hills and such.  Take care, and may Karana keep your path clear and our lakes full.");
		#:: Give a 18103 - Rat Ear Pie
		quest::summonitem(18103);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 5);			#:: + Arcane Scientists
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(296, -1);		#:: - Opal Darkbriar
		quest::faction(330, -1);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Match one 13050 - Giant Rat Ear
	elsif (plugin::check_handin(\%itemcount, 13050 => 1)) {
		quest::say("Hey... wow... Now THESE are some good, meaty ears... These will make one great rat ear pie... Tell ya what, kid... bring me a few more o' these beauties, and I'll give you my secret recipe for cooking 'em.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 1);			#:: + Arcane Scientists
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(296, -1);		#:: - Opal Darkbriar
		quest::faction(330, -1);		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(50);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
