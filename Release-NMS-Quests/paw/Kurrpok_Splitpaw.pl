sub EVENT_DEATH_COMPLETE {
	#:: Identify the killers
	foreach $pc ($entity_list->GetClientList()) {
		#:: Match if the killers were players
		if ($pc->GetID() == $killer_id) {
			#:: Spawn one and only one The Lair of the Splitpaw >> #a_gnoll_prisoner (18110)
			quest::unique_spawn(18110, 1, 0, -181, 606, 4.19, 0);
			#:: Send a signal with the players entity id to The Lair of the Splitpaw >> #a_gnoll_prisoner (18110) with a 10 second delay
			quest::signalwith(18110, $killer_id, 10);
		}
	}
}
