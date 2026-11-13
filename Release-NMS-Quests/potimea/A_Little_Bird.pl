sub EVENT_SAY {
	plugin::OfferStandardInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	# The fleet is per-zone npc_types rows (static zone lastnames), but spawn
	# stamps the zone long name onto the nameplate anyway so any row without
	# one still reads "A Little Bird, <Zone>".
	$npc->ChangeLastName($zoneln);

	# The Forsaken Hourglass (potimea version 9) is itself an instance boot, but
	# this herald is its zone furniture and stays: v389 plants it on the tower
	# top as the anchor for the personal-instance offer and whatever follows.
	# No other potimea boot has a spawn row for this npc, so the fleet's depop
	# rule still holds for any future rows (static/farming instances must not
	# carry a herald).
	if ($instanceversion > 0 && $instanceversion != 9) {
		$npc->Depop();
	}
}
