sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I am Nexvok, master wizard of the Dismal Rage.  My associates Heneva and Konious and I provide our services to master Zarn on a regular basis.  People of our talent are in high demand. and Pietro pays well, so we are, of course, very loyal.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18854 - A tattered note
	if (plugin::check_handin(\%itemcount, 18854 => 1)) {
		quest::say("Ah ha.. Fresh meat. here, put this on.. you're one of us now. Do your best to do your worst.");
		#:: Give item 13564 - Dirty Torn Robe*
		quest::summonitem(13564);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 		#:: + Dismal Rage
		quest::faction(281, -15); 		#:: - Knights of Truth
		quest::faction(296, 20); 		#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
