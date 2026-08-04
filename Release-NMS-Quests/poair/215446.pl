

sub EVENT_DEATH_COMPLETE {

		#Check if NPC is up
	if (!$entity_list->IsMobSpawnedByNpcTypeID(215446)) {

			quest::spawn2(215448,0,0,-375,-659,105.13,11.8); # Real
			quest::spawn2(215449,0,0,-375,-659,105.13,11.8); # Real
			quest::spawn2(215449,0,0,-375,-659,105.13,11.8); # Real
			quest::spawn2(215449,0,0,-375,-659,105.13,11.8); # Real
			quest::spawn2(215449,0,0,-375,-659,105.13,11.8); # Real
		}
		}
