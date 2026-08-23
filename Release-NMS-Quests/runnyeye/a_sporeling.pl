sub EVENT_AGGRO {
	quest::emote("is not fully developed. It needs a host body to feed upon. Yours!");
}

sub EVENT_SPAWN {
	#:: Create a timer 'depop' that loops every 300 seconds (5 min)
	quest::settimer("depop", 300);
}

sub EVENT_TIMER {
	#:: Match the timer 'depop'
	if ($timer eq "depop") {
		#:: Stop the timer 'depop'
		quest::stoptimer("depop");
		#:: Depop
		quest::depop();
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
