sub EVENT_SPAWN {
	quest::say("Huh? What the... oh, no... S'ragg! PLEASE NO! Bertoxxulous save me!");
	#:: Send a signal '1' to The Qeynos Aqueduct System >> Sragg_Bloodheart (45091) with 10 second delay
	quest::signalwith(45091, 1, 10);
}

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

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
