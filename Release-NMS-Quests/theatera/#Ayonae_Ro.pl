# Deathknell (theatera) Ayonae Ro - TSS progression flag.
# Custom handler (not plugin::handle_death) because the TSS objective is named
# "Deathknell" (the raid zone), which matches no NPC name; the memory NPC gets
# a bespoke Flag-Name so the zone's raid boss counts toward TSS.
sub EVENT_DEATH_COMPLETE {
    my $flag_mob = quest::spawn2(26000, 0, 0, $x, $y, ($z + 10), 0); # Spawn a flag mob
    my $new_npc = $entity_list->GetNPCByID($flag_mob);

    $new_npc->SetEntityVariable("Flag-Name", "deathknell");
    $new_npc->SetEntityVariable("Stage-Name", "TSS");

    my $killer_guild_id = plugin::get_memory_killer_guild_id($entity_list);
    if ($killer_guild_id) {
        $new_npc->SetEntityVariable("Killer-Guild-ID", $killer_guild_id);
    }
}
