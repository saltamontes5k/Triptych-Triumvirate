sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::emote("twists into battle, gathering loose debris as it goes.");
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::emote("slows its spinning until it eventually disappears entirely.");
}
