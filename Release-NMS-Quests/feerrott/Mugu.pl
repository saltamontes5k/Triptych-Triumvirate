sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 3001003 => 1)) {
		quest::say("A lost mirror? Let me have a look... oh no, I've broken it! Take the pieces, perhaps the witch can mend it.");
		quest::summonitem(3001004);
	} else {
		plugin::return_items(\%itemcount);
	}
}
