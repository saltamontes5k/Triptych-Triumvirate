sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What do you want? Leave me be! Can't a man [drown his sorrows] in peace!?");
	}
	elsif ($text=~/drown his sorrows/i) {
		quest::say("'I can buy my own drinks, thank you. Now, leave me alone.");
	}
	elsif ($text=~/lynuga/i) {
		quest::say("As if I care what you are going to do.");
		#:: Set faction
		quest::faction(346, -25);			#:: - Commons Residents
	}
	elsif ($text=~/yiz/i) {
		quest::say("Yiz?! That worthless hunk of orc dung... Last I heard, he was still searching for those [blasted eyes].");
	}
	elsif ($text=~/blasted eyes/i) {
		quest::say("That is none of your business, bub!");
	}
}

sub EVENT_ITEM {
	#:: Match a 18010 - Torn Parchment
	if (plugin::check_handin(\%itemcount, 18010 => 1 )) {
		quest::say("Peh! He thinks this old skull he found is a legendary skull of Wun Toque. It is said, a wizard who possesses one is granted power and intelligence far beyond those of his peers. Yiz was searching for the skulls missing ruby eyes. It seems he found the location of the first eye. Hmm.. Lynuga.. Lynuga.. I think I have heard that name before.. Yeah! Now I remember. I met her in the Foreign Quarter of Neria.. um.. Highpass Hold. She was trying to hawk some stolen gems! I think she mumbled something about going home to Grobb. I sure don't have time to track her down.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(346, 10); 		#:: + Commons Residents
		quest::faction(330, 2); 		#:: + Freeport Militia
		quest::faction(281, 2); 		#:: + Knights of Truth
		quest::faction(362, 1); 		#:: + Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Match a 13987 - Jeweled Skull
	elsif (plugin::check_handin(\%itemcount, 13987 => 1)) {
		quest::say("You found it!? My sap of a brother was right after all! I sure don't want that thing. It sends shivers down my spine just holding it. Here. Take it!");
		#:: Give a 13988 - Jeweled Skull
		quest::summonitem(13988);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(346, 100); 		#:: + Commons Residents
		quest::faction(330, 25); 		#:: + Freeport Militia
		quest::faction(281, 25); 		#:: + Knights of Truth
		quest::faction(362, 15); 		#:: + Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Match a 13988 - Jeweled Skull
	elsif (plugin::check_handin(\%itemcount, 13988 => 1)) {
		quest::say("You found it!? My sap of a brother was right after all! I sure don't want that thing. It sends shivers down my spine just holding it. Here. Take it!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(346, 25); 		#:: + Commons Residents
		quest::faction(330, 6); 		#:: + Freeport Militia
		quest::faction(281, 6); 		#:: + Knights of Truth
		quest::faction(362, 3); 		#:: + Priests of Marr
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
