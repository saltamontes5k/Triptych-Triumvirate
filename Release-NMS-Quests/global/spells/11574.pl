# Fae Dust (Faerie Catching Bottle) - Troublemakers in Faydark (task 620005)
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	my $n = lc($npc->GetCleanName());
	if ($n =~ /faerie|fairy|pixie/) {
		$client->UpdateTaskActivity(620005, 0, 1);
		$npc->Depop();
	}
}

sub EVENT_SPELL_EFFECT {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	# Release the captured troublemakers in the Lesser Faydark.
	if ($client->GetZoneID() == 57) {
		$client->UpdateTaskActivity(620005, 1, 1);
	}
}
