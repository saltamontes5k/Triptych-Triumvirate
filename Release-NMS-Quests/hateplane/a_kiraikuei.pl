sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("I shall defeat you with my superior skill and style!");
	}
}

sub EVENT_SLAY {
	quest::say("You are weak!");
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My form was weak, your style was excellent. I hate you!");
}
