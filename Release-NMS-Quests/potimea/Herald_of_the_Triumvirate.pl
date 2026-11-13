sub EVENT_SAY {
	plugin::OfferStandardInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	# One shared npc_types row is spawned in every zone, so the stored lastname can
	# never match: stamp the zone long name onto the nameplate at spawn instead.
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
