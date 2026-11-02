# Grave Dig - spell 44026 (moved from 122100, above the RoF2 client ceiling),
# cast by Edmund's Shovel (3001008) on
# a_disturbed_earth (1500200072).  2009 "Digging Their Graves" (620013).
# Spawns either a_tattooed_zombie (1500200074, loot the flesh) or
# a_disturbed_spirit (1500200073).
sub EVENT_SPELL_EFFECT_NPC {
	my $client = $entity_list->GetClientByID($caster_id);
	if (!$client) { return; }
	if ($npc->GetNPCTypeID() != 1500200072) {
		$client->Message(15, "There is nothing to dig here.");
		return;
	}
	if (!$client->IsTaskActive(620013)) {
		$client->Message(15, "You dig out a handful of cold dirt. Edmund would want something more... alive. (Take his task first.)");
		return;
	}
	my $x = $npc->GetX() + 8;
	my $y = $npc->GetY();
	my $z = $npc->GetZ();
	if (int(rand(2))) {
		quest::spawn2(1500200074, 0, 0, $x, $y, $z, 0);
		$client->Message(15, "The earth heaves - a Tattooed Zombie claws its way out!");
	} else {
		quest::spawn2(1500200073, 0, 0, $x, $y, $z, 0);
		$client->Message(15, "The earth heaves - a Disturbed Spirit rises, howling!");
	}
	$npc->Depop();
}
