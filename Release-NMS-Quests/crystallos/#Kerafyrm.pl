# Crystallos Kerafyrm - SoD progression flag.
# Custom handler (not plugin::handle_death) because the objective name must be
# distinct from the Sleeper's Tomb "Kerafyrm" objective; the memory NPC gets a
# bespoke Flag-Name so both kills count separately toward SoD.
sub EVENT_DEATH_COMPLETE {
    my $flag_mob = quest::spawn2(26000, 0, 0, $x, $y, ($z + 10), 0); # Spawn a flag mob
    my $new_npc = $entity_list->GetNPCByID($flag_mob);

    $new_npc->SetEntityVariable("Flag-Name", "kerafyrm-crystallos");
    $new_npc->SetEntityVariable("Stage-Name", "SoD");
}
