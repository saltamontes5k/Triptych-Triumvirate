sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);

    my $killer = $entity_list->GetClientByID($killer_id);

    if ($killer && int(rand(100)) == 0) {
        plugin::AddTitleFlag(200);
    }

    # Bard epic (live behavior): the undead bard rises where Trakanon falls,
    # so the chain can continue without waiting out his respawn timer. A fresh
    # bard carries no lute-body flag, so killing him cannot chain another
    # #Trakanon - only the real hand-in (An_Undead_Bard.pl) does that.
    quest::spawn2(89168, 0, 0, $x, $y, $z, 0); # NPC: An_Undead_Bard
}