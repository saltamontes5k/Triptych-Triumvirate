sub EVENT_TARGET_CHANGE {
	if ($ulevel > 80) {
		if ($status < 80) {
			if ($client->GetTarget()->GetCleanName() eq "Lord Nagafen") {
				quest::ze(0, "I will not fight you, but I will banish you!");
				#:: Move the client to Lavastorm at the specified coordinates
				$client->MovePC(27, 485, 911, 55, 106);
			}
		}
	}
}
sub EVENT_ENTERZONE {
	$expedition = $client->GetExpedition();

	if (!$expedition || $expedition->GetZoneVersion() != 1) {
		return;
	}

	$bind = $client->GetBindZoneID;
	$bindh = $client->GetBindHeading;
	$bindx = $client->GetBindX;
	$bindy = $client->GetBindY;
	$bindz = $client->GetBindZ;
	
	if (!plugin::is_stage_complete($client, 'FNagafen')) {
		$client->Message(7, "You don't belong here!");
		$client->MovePC($bind, $bindx, $bindy, $bindz, $bindh);
	}
}