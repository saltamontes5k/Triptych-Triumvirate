sub EVENT_SPAWN 
{
	$counter = 0;
}    

sub EVENT_SIGNAL 
{
	if ($signal == 1 && $zone->GetVariable("mist_event_start") != "" && $zone->GetVariable("mist_done") == "") 
	{
     		$counter+=1;
     
     		if ($counter == 4) 
     		{
			quest::spawn2(215070,0,0,323.7,-721.3,439.3,165.8); # NPC: #Melernil_Faal`Armanna
        	}
     	}
     	elsif ($signal == 2 && $zone->GetVariable("mist_event_start") != "" && $zone->GetVariable("mist_done") == "") 
     	{
        	quest::spawn2(215071,0,0,-1571.6,-570.0,343.6,381.8); # NPC: #Avatar_of_Mist
		quest::depop_withtimer(215023);
     	}
     	elsif ($signal == 3  && $zone->GetVariable("mist_done") == "") 
     	{
     		$zone->SetVariable("mist_done","1");
	}
	elsif ($signal == 4 && $zone->GetVariable("mist_event_start") == "" && $zone->GetVariable("mist_done") == "") 
	{
		#A_Phoenix_Breezewing, A_Wind_Pheonix X2, Servitor_of_Xegony, Spiritfrenzied_Phoenix, Ardent_Phoenix_of_Xegony, A_Phoenix_Searedwing, Calebgrothiel
		if(!$entity_list->IsMobSpawnedByNpcTypeID(215058) && !$entity_list->IsMobSpawnedByNpcTypeID(215026) && !$entity_list->IsMobSpawnedByNpcTypeID(215025) && !$entity_list->IsMobSpawnedByNpcTypeID(215027) && !$entity_list->IsMobSpawnedByNpcTypeID(215062) && !$entity_list->IsMobSpawnedByNpcTypeID(215059) && !$entity_list->IsMobSpawnedByNpcTypeID(215028) && !$entity_list->IsMobSpawnedByNpcTypeID(215061)) 
		{
			quest::spawn2(215069,0,0,304.2,-792.2,441.6,30.4); # NPC: A_Phoenix_Windsurger
			quest::spawn2(215069,0,0,348.4,-632.2,442.3,280.2); # NPC: A_Phoenix_Windsurger
			quest::spawn2(215069,0,0,391.7,-736.2,438.1,406.8); # NPC: A_Phoenix_Windsurger
			quest::spawn2(215069,0,0,260,-699.8,444.5,151); # NPC: A_Phoenix_Windsurger
			$zone->SetVariable("mist_event_start","1");
			$counter=0;
		}
	}
	elsif ($signal == 5)
	{
		$zone->DeleteVariable("mist_done");
		$zone->DeleteVariable("mist_event_started");
	}
}
