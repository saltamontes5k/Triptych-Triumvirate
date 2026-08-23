sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $name.  If you have come to seek the way of Discord in your life, then ask me about your [Tome of Order and Discord].");
	}
	elsif ($text=~/tome of order and discord/i) {
		quest::say("The Tome of Order and Discord was penned by the seventh member of the Tribunal and has become the key to a life of Discord, in spite of the author's pitiful warnings. Do you not have one, child of Order? Would you [like to read] it?");
	}
	elsif ($text=~/read/i) {
		quest::say("Very well. Here you go. Simply return it to me to be released from the chains of Order.");
		#:: Summon a 18700 - Tome of Order and Discord
		quest::summonitem(18700);
	}
}

sub EVENT_ITEM {
	#:: Match a 18700 - Tome of Order and Discord
	if (plugin::check_handin(\%itemcount, 18700 => 1)) {
		quest::say("I see you wish to join us in Discord! Welcome! By turning your back on the protection of Order you are now open to many more opportunities for glory and power. Remember that you can now be harmed by those who have also heard the call of Discord.");
		#:: Ding!
		quest::ding();
		#:: Turn pvp on
		quest::pvp("on");
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
