sub EVENT_SPAWN {
	quest::emote("focuses her gaze on you.");
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Your intolerable reputation insults all in this realm.");
	}
}

sub EVENT_AGGRO {
	$raceplural = "${race}s";
	quest::say("$raceplural have no place in our realm!");
}
