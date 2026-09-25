# Pound (Blessed Shillelagh) - Necromancer's Garden (task 620006)
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	if ($client->GetZoneID() == 54) {
		$client->UpdateTaskActivity(620006, 0, 1);
		$npc->Depop();
	}
}
