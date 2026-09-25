sub EVENT_SAY {
	plugin::OfferStandardInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	# One shared npc_types row is spawned in every zone, so the stored lastname can
	# never match: stamp the zone long name onto the nameplate at spawn instead.
	$npc->ChangeLastName($zoneln);

	if ($instanceversion > 0) {
		$npc->Depop();
	}
}
