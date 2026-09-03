sub EVENT_CLICKDOOR {
	return if ($doorid != 56 && $doorid != 57);

	my @brood;
	if (defined($instanceversion) && $instanceversion == 100) {
		# Veeshan's Peak 2.0 expedition instance: the revamped warders
		@brood = (1500000505, 1500000501, 1500000503, 1500000502, 1500000504); # Xygoz, Druushk, Nexona, Hoshkar, Silverwing
	} else {
		# Classic zone
		@brood = (108053, 108040, 108047, 108043, 108050); # Xygoz, Druushk, Nexona, Hoshkar, Silverwing
	}

	my $dragonsup = 0;
	foreach my $id (@brood) {
		if ($entity_list->IsMobSpawnedByNpcTypeID($id)) {
			$dragonsup++;
		}
	}

	if ($dragonsup == 0) {
		$client->Message(0, "You got the door open.");
		quest::forcedooropen(56);
		quest::forcedooropen(57);
	}
	else {
		$client->Message(0, "A seal has been placed on this door by Phara Dar. Perhaps there is a way to remove it.");
	}
}
