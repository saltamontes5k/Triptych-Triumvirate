sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Ooh... Aaah!! No! Please! Ouch.... Aarghhhhh!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What?  Who the heck are you and how do you know my name?!  Never mind... Just leave me alone!");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	if ($wp == 1) {
		#:: Create a ground spawn 18802 - Sealed Letter at the current location
		quest::creategroundobject(18802, $x, $y, $z, 0, 7200);
	}
	elsif (($wp == 5) || ($wp == 15) || ($wp == 35) || ($wp == 60) || ($wp == 66)) {
		quest::say("Sragg is going to have my head for losing that letter.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
