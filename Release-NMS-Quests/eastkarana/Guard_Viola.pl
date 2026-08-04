sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		#:: Create a scalar variable to store a target entity
		my $cur_target = $npc->GetHateTop();
		#:: Match if target entity exists
		if ($cur_target) {
			#:: Create a scalar variable to store the target's name in clean format
			my $target_name = $cur_target->GetCleanName();
			quest::say("Time to die $target_name!");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
