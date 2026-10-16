sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);

    # NMS progression: Solusek Ro is a Secrets of Faydwer objective (Solteris pair).
    my $flag_mob = quest::spawn2(26000, 0, 0, $x, $y, ($z + 10), 0); # Spawn a flag mob
    my $new_npc = $entity_list->GetNPCByID($flag_mob);

    $new_npc->SetEntityVariable("Flag-Name", "solusek ro");
    $new_npc->SetEntityVariable("Stage-Name", "SoF");

    my $killer_guild_id = plugin::get_memory_killer_guild_id($entity_list);
    if ($killer_guild_id) {
        $new_npc->SetEntityVariable("Killer-Guild-ID", $killer_guild_id);
    }
}
