sub EVENT_SPAWN 
{
	$counter = 0;
}    

sub EVENT_SIGNAL 
{
	if ($signal == 1 && $zone->GetVariable("smoke_event_start") != "" && $zone->GetVariable("smoke_done") == "") 
	{
		$counter+=1;
		
     		if ($counter == 4) 
     		{
        		quest::spawn2(215454,0,0,-445.6,-1291.9,317.6,140.2); # NPC: An_Elemental_Masterpiece
        	}
     	}
     	elsif ($signal == 2 && $zone->GetVariable("smoke_event_start") != ""  && $zone->GetVariable("smoke_done") == "") 
     	{
     		quest::spawn2(215435,0,0,1395.9,-681.3,15.1,510.2); # NPC: #Avatar_of_Smoke
        	quest::depop_withtimer(215055);
     	}
     	elsif ($signal == 3  && $zone->GetVariable("smoke_done") == "") 
     	{
        	$zone->SetVariable("smoke_done","1");
     	}
	elsif ($signal == 4 && $zone->GetVariable("smoke_event_start") == "" && $zone->GetVariable("smoke_done") == "") 
	{
		#A_Confused_Air_Elemental
		if(!$entity_list->IsMobSpawnedByNpcTypeID(215012)) 
		{
			quest::spawn2(215066,0,0,-403.1,-1375.5,320.8,469.8); # NPC: An_Elemental_Champion
			quest::spawn2(215066,0,0,-501.9,-1205.9,318.6,198); # NPC: An_Elemental_Champion
			quest::spawn2(215066,0,0,-341.1,-1245.2,317.6,365.6); # NPC: An_Elemental_Champion
			quest::spawn2(215066,0,0,-523.3,-1288.2,321.7,126); # NPC: An_Elemental_Champion
			$zone->SetVariable("smoke_event_start","1");
			$counter=0;
		}
	}
	elsif ($signal == 5)
	{
		$zone->DeleteVariable("smoke_done");
		$zone->DeleteVariable("smoke_event_started");
	}
}
