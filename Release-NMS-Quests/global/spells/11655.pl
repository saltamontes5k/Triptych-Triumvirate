# Skeletal Expulsion - Skeleton Zapping (task 620004)
# The scythe only works on skeleton/undead targets.
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;
	my $n = lc($npc->GetCleanName());
	if ($npc->GetBodyType() == 3 || $n =~ /skeleton|undead/) {
		$client->UpdateTaskActivity(620004, 0, 1);
		$npc->Kill();
	}
}
