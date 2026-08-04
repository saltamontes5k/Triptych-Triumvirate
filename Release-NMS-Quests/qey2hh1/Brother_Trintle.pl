sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("For Bertoxxulous, I shall spill your guts upon the floor!");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Retrieve the entity id for The Western Plains of Karana >> Brother_Estle (12043)
	my $npc_ent = $entity_list->GetMobByNpcTypeID(12043);
	#:: Match if entity is found
	if (defined($npc_ent)) {
		if ($npc_ent->CalculateDistance($x, $y, $z) < 100) {
			#:: Get him.
			$npc->Attack($npc_ent);
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
