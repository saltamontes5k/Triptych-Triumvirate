sub EVENT_SPAWN {
	#:: Create a timer "depop" that loops every 1200 seconds (20 minutes)
	quest::settimer("depop",1200);
}

sub EVENT_TIMER {
	#:: Match timer "depop"
	if ($timer eq "depop") {
		#:: Stop the timer from looping
		quest::stoptimer("depop");
		#:: Depop
		quest::depop();
	}
}
