sub EVENT_SPAWN {
	#:: Create a timer 'depop' that triggers in 4800 seconds (80 min)
	quest::settimer("depop", 4800);
}

sub EVENT_TIMER {
	#:: Match if timer named "depop"
	if ($timer eq "depop") {
		#:: Stop the timer "depop"
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop();
	}
}
