sub EVENT_TARGET_CHANGE {
	if ($ulevel > 80) {
		if ($status < 80) {
			#:: OrigName + CleanNpcName so the banish also catches the Fabled
			#:: rename (The_Fabled_Lady_Vox) - FABLED-ENCOUNTERS.md 6.6
			if (plugin::CleanNpcName($client->GetTarget()->GetOrigName()) eq "Lady Vox") {
				quest::ze(0, "I will not fight you, but I will banish you!");
				#:: Move the client to Everfrost Peaks at the specified coordinates
				$client->MovePC(30, -7024, 2020, -60.7, 0);
			}
		}
	}
}
sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	#:: The Fabled Lady Vox raid lives on permafrost version 2+ (requested
	#:: from the Bazaar's #Sage_of_Anachronism).
	if (!$expedition || $expedition->GetZoneVersion() != 2) {
		return;
	}

	$bind = $client->GetBindZoneID;
	$bindh = $client->GetBindHeading;
	$bindx = $client->GetBindX;
	$bindy = $client->GetBindY;
	$bindz = $client->GetBindZ;

	#:: FRoK gate: Quarm dead (FNagafen stage objective) -- mirrors the
	#:: Fabled Nagafen entry gate.
	if (!plugin::is_stage_complete($client, 'FNagafen')) {
		$client->Message(7, "You don't belong here!");
		$client->MovePC($bind, $bindx, $bindy, $bindz, $bindh);
	}
}
