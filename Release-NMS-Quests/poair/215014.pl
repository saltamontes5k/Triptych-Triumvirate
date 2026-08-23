sub EVENT_SPAWN {
my $airtrigger = (215013,215014,215002);
}

sub EVENT_DEATH_COMPLETE {

	my $airtrigger = (215013,215014,215002);

	if (!$entity_list->IsMobSpawnedByNpcTypeID($airtrigger))
	   {


		#Check if NPC is up
	if (!$entity_list->IsMobSpawnedByNpcTypeID(215447)) {

			quest::spawn2(215447,0,0,-375,-659,105.13,11.8); # NPC: Stormrider Priest of Destruction
		}
		}
	}
