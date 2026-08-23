sub EVENT_DEATH_COMPLETE {
	#:: Check if The Southern Plains of Karana >> #Quillmane (14139) is spawned
	if (!$entity_list->IsMobSpawnedByNpcTypeID(14139)) {
		#:: Create a scalar variable to store a random number 1-100
		my $RandomChance = plugin::RandomRange(1, 100);
		#:: Three percent chance at each spawn point
		if ($RandomChance < 4) {
			#:: Spawn The Southern Plains of Karana >> #Quillmane (14139) on grid 101
			quest::spawn2(14139, 101, 0, 3210, -6821, 38, 193);
		}
		elsif ($RandomChance >= 4 && $RandomChance < 7) {
			#:: Spawn The Southern Plains of Karana >> #Quillmane (14139) on grid 102
			quest::spawn2(14139, 102, 0, -2761, -6076, 1, 4);
		}
		elsif ($RandomChance >= 7 && $RandomChance < 10) {
			#:: Spawn The Southern Plains of Karana >> #Quillmane (14139) on grid 103
			quest::spawn2(14139, 103, 0, -2334, 1296, 39, 247);
		}
	}
}
