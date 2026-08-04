sub EVENT_DEATH_COMPLETE {
    quest::debug("name: " . $npc->GetCleanName() . " : " . plugin::subflag_exists($npc->GetCleanName()));
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}