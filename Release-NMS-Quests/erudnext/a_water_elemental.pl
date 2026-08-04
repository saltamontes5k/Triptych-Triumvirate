sub EVENT_SPAWN {
	#:: Create a timer 'depop' that loops every 180 seconds (3 min)
	quest::settimer("depop", 180);
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("The pain cellars of the Tribunal await! The High Guard's death shall be avenged");
	}
}

sub EVENT_TIMER {
	#:: Match timer 'depop'
	if ($timer eq "depop") {
		#:: Stop the timer from triggering
		quest::stoptimer("depop");
		#:: Depop without spawn timer
		quest::depop();
	}
}
