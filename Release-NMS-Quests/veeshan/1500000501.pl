# Veeshan's Peak 2.0 warder - Druushk (instance version 100).
# When the last of the five warders falls, Phara Dar's lair seal is broken.

sub EVENT_DEATH {
	return if (!defined($instanceversion) || $instanceversion != 100);

	my $alive = 0;
	foreach my $id (1500000502, 1500000503, 1500000504, 1500000505) { # Hoshkar, Nexona, Silverwing, Xygoz
		$alive++ if $entity_list->IsMobSpawnedByNpcTypeID($id);
	}
	if ($alive == 0) {
		quest::forcedooropen(56);
		quest::forcedooropen(57);
		quest::shout("With Druushk's fall the last of the brood is spent - the seals upon Phara Dar's lair shatter!");
	}
}
