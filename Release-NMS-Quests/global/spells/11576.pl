# Flames of Light (Torch of Undead Warding) - Undead Rising (task 620007)
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	if ($npc->GetNPCTypeID() == 1500200024) {
		$client->UpdateTaskActivity(620007, 1, 1);
		$npc->Kill();
	}
}
