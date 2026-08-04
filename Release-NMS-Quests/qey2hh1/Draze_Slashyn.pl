sub EVENT_SPAWN {
	#:: Move to the specified location and guard 
	quest::moveto(-7756, -3726, 1, 0, 1);
	#:: Create a timer 'arrived' that loops every 5 seconds
	quest::settimer("arrived", 5);
}

sub EVENT_TIMER {
	#:: Match the timer 'arrived'
	if ($timer eq "arrived") {
		#:: Match path-to location
		if (($x == -7756) && ($y == -3726)) {
			quest::shout("Come out of that house, Linaya Sowlin!! I am waiting! It is time for you to die!");
			#:: Stop the timer 'arrived' from triggering
			quest::stoptimer("arrived");
		}
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Step aside. I have no quarrel with you.");
	}
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("I shall chop you down as your people chopped down the beauty of the forests!!");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("Your act of murder will not go unnoticed by the Unkempt Druids or nature itself!!");
}
