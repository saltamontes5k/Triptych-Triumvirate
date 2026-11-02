# Wake of Tranquility (Quellious' Wand of Tranquility, blessing task 700181)
# Id-gated: only reacts on the two drunken miscreants in Shadow Haven.
# Wand click -> AE calm lands on the miscreant -> they accept the peace and wander off.
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	return unless $client->IsTaskActive(700181);

	if ($npc->GetNPCTypeID() == 600157) {
		$entity_list->MessageClose($npc, 1, 100, 4, "a drunken Fordel miscreant says, 'Ahh... the fighting... why was I fighting again? I think I'll go sleep it off.'");
		$client->UpdateTaskActivity(700181, 4, 1);
		$npc->Depop();
	}
	elsif ($npc->GetNPCTypeID() == 600158) {
		$entity_list->MessageClose($npc, 1, 100, 4, "a drunken Midst miscreant says, 'Whew... it's like the anger just rained right off me. G'night, friends.'");
		$client->UpdateTaskActivity(700181, 5, 1);
		$npc->Depop();
	}
}
