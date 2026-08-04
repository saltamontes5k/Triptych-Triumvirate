sub EVENT_ITEM {
	#:: Turn in of Large Crate of Mining Supplies 19930 for Rogue Errands Quest - spawned by Rigg_Nostra
	if (plugin::check_handin(\%itemcount, 19930 => 1)) {
		quest::say("Arg");
		#:: Give a 19918 - Rough Blue Gem
		quest::summonitem(19918);
		#:: Ding!
		quest::ding();
		#:: Set a timer 'depop' that loops every 5 seconds
		quest::settimer("depop", 5);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_TIMER {
	#:: Match timer 'depop'
	if ($timer eq "depop") {
		quest::depop();
	}
}
