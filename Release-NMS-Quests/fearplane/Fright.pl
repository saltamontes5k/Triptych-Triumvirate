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

sub EVENT_SIGNAL {
	#:: Match a signal '1' sent from /fearplane/Cazic_Thule.pl
	if ($signal == 1) {
		quest::say("Such is the will of Cazic-Thule!");
	}
	#:: Match a signal '2' sent from /fearplane/Cazic_Thule.pl
	elsif ($signal == 2) {
		my $getmobbynpctype = $entity_list->GetMobByNpcTypeID(72003);
		my $follow_target = $getmobbynpctype->GetID();
		quest::follow($follow_target);
		quest::say("We obey!");
	}
	#:: Match a signal '3' sent from /fearplane/Cazic_Thule.pl
	elsif ($signal == 3) {
		quest::sfollow();
	}
}

#:: sub EVENT_DEATH_COMPLETE {
#:: 	#:: Spawn a The Plane of Fear >> Iksar_broodling (72105) at the current location 75 percent of the time
#:: 	my $Random = quest::ChooseRandom(72105, 72105, 72105, 0);
#:: 	quest::spawn2($Random, 0, 0, $x, $y, $z, $h);
#:: }
