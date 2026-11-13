sub EVENT_CLICKDOOR {
  if(($doorid == 1) && !defined $qglobals{dragon_not_ready}) {
    quest::setglobal("door_two",1,3,"S60");
    $client->Message(4,"The globe begins to spin faster and faster...");
  }
  if(($doorid == 2) && !defined $qglobals{dragon_not_ready}) {
    quest::setglobal("door_three",1,3,"S60");
    $client->Message(4,"The globe begins to spin faster and faster...");
  }
  if(($doorid == 3) && !defined $qglobals{dragon_not_ready}) {
    quest::setglobal("door_four",1,3,"S60");
    $client->Message(4,"The globe begins to spin faster and faster...");
  }
  if(($doorid == 232) && !defined $qglobals{dragon_not_ready}) {
    quest::setglobal("door_one",1,3,"S60");
    $client->Message(4,"The globe begins to spin faster and faster...");
  }
  if(($doorid == 1) && $dragon_not_ready == 1) {
    $client->Message(4,"The globe does not seem to do anything");
  }
  if(($doorid == 2) && $dragon_not_ready == 1) {
    $client->Message(4,"The globe does not seem to do anything");
  }
  if(($doorid == 3) && $dragon_not_ready == 1) {
    $client->Message(4,"The globe does not seem to do anything");
  }
  if(($doorid == 232) && $dragon_not_ready == 1) {
    $client->Message(4,"The globe does not seem to do anything");
  }
  if($doorid == 135) {
    # Let otherwise completed SoV flags allow entry instead of key
    if (plugin::is_stage_complete_2($client, 'SoV')) {
      quest::debug("Allowing access through SoV flag");
      quest::movepc(108,1682,41,25.9); # Zone: veeshan
    } else {
      if (!plugin::is_eligible_for_zone($client, 'veeshan', 1)) {
        return 1;
      } else {
          if(plugin::check_hasitem($client, 20884) && !$client->KeyRingCheck(20884)) {
              $client->KeyRingAdd(20884);
          }
          if($client->KeyRingCheck(20884) || ($status >= 50)) {
              quest::movepc(108,1682,41,25.9); # Zone: veeshan
          }
          else {
              $client->Message(13, "You lack the will to use this object!");
          }
      }
    }
  }
}
sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	#:: The Fabled Talendor raid lives on skyfire version 2+ (requested
	#:: from the Bazaar's #Sage_of_Anachronism).
	if (!$expedition || $expedition->GetZoneVersion() != 2) {
		return;
	}

	if ($client->GetGM()) {
		return;
	}

	$bind = $client->GetBindZoneID;
	$bindh = $client->GetBindHeading;
	$bindx = $client->GetBindX;
	$bindy = $client->GetBindY;
	$bindz = $client->GetBindZ;

	#:: FSoV gate: FRoK complete -- both Fabled subflags recorded under
	#:: the FNagafen stage (fabled_nagafen + fabled_vox).
	if (plugin::GetSubflag($client, 'FNagafen', 'fabled_nagafen') ne "1"
		|| plugin::GetSubflag($client, 'FNagafen', 'fabled_vox') ne "1") {
		$client->Message(7, "You don't belong here!");
		$client->MovePC($bind, $bindx, $bindy, $bindz, $bindh);
	}
}