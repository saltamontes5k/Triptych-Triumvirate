sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	#:: The Fabled Gorenaire raid lives on dreadlands version 2+ (requested
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
