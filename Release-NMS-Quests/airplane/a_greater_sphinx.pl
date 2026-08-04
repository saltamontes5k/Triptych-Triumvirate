sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		#:: Create a timer 'dt' that triggers every 45 seconds
		quest::settimer("dt", 45);
	}
	else {
		#:: Stop the timer 'dt' from triggering
		quest::stoptimer("dt");
	}
}

sub EVENT_TIMER {
	#:: Match timer 'dt'
	if ($timer eq "dt") {
		$target = $npc->GetHateTop();
		if ($target->IsPet()) {
			$owner = $target->GetOwnerID();
			$npc->CastSpell(982, $owner);
		}
		else {
			$npc->CastSpell(982, $target);
		}
	}
}
