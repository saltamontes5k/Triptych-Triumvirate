sub EVENT_AGGRO {
	quest::say("Now you shall know the skill of the Bloodforge Brigade!");
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Now you shall know the skill of the Bloodforge Brigade!");
		quest::stoptimer("despawn");
	}
	#:: Match combat state 0 - left combat
	elsif ($combat_state == 0) {
		#:: Create a timer 'despawn' that triggers every 300 seconds (5 min)
		quest::settimer("despawn", 300);
	}
}

sub EVENT_TIMER {
	#:: Match timer 'despawn'
	if ($timer eq "despawn") {
		if ($combat_state == 0) {
			quest::stoptimer("despawn");
			quest::depop();
		}
	}
}
