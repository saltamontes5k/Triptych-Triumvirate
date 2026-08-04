sub EVENT_SPAWN {
	#:: Disable the spawn timer for 151562 - spawngroup ID 113004 - npcIDs 15138 (Droon) and 15160 (Proon)
	quest::disable_spawn2(151562);
}

sub EVENT_DEATH_COMPLETE {
	#:: Enable the spawn timer for 151562 - spawngroup ID 113004 - npcIDs 15138 (Droon) and 15160 (Proon)
	quest::enable_spawn2(151562);
}
