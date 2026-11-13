sub EVENT_TARGET_CHANGE {
	if ($ulevel > 80) {
		if ($status < 80) {
			#:: OrigName + CleanNpcName so the banish also catches the Fabled
			#:: rename (The_Fabled_Lord_Nagafen) - FABLED-ENCOUNTERS.md 6.6
			if (plugin::CleanNpcName($client->GetTarget()->GetOrigName()) eq "Lord Nagafen") {
				quest::ze(0, "I will not fight you, but I will banish you!");
				#:: Move the client to Lavastorm at the specified coordinates
				$client->MovePC(27, 485, 911, 55, 106);
			}
		}
	}
}
sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	#:: The Fabled Lord Nagafen raid lives on soldungb version 2+
	#:: (requested from the Bazaar's #Sage_of_Anachronism).
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

	#:: Gate: Quarm dead (FNagafen stage objective) -- the design sheet's
	#:: tier rows describe future ordering, the live gate stays on Quarm.
	if (!plugin::is_stage_complete($client, 'FNagafen')) {
		$client->Message(7, "You don't belong here!");
		$client->MovePC($bind, $bindx, $bindy, $bindz, $bindh);
	}
}
