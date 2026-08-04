sub EVENT_SAY {
	plugin::OfferStandardInstance($zoneln, 1, 72, $zonesn);
}

sub EVENT_SPAWN {
	if ($instanceversion > 0) {
		$npc->Depop();
	}
}