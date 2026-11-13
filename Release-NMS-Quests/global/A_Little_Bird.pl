sub EVENT_SAY {
	plugin::OfferStandardInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	# The fleet is per-zone npc_types rows (static zone lastnames), but spawn
	# stamps the zone long name onto the nameplate anyway so any row without
	# one still reads "A Little Bird, <Zone>".
	$npc->ChangeLastName($zoneln);

	if ($instanceversion > 0) {
		$npc->Depop();
	}
}
