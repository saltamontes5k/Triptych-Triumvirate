# Prod (Rongol's Pitchfork) - Scarecrow Roundup (task 620010)
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	my $n = lc($npc->GetCleanName());
	if ($n =~ /scarecrow/) {
		$client->UpdateTaskActivity(620010, 0, 1);
	}
}
