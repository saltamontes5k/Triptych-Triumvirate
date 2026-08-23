# Clockwork Banker

sub EVENT_TICK {
    if (!$npc->GetEntityVariable("owner") || !$entity_list->GetClientByCharID($npc->GetEntityVariable("owner"))) {
        $npc->Depop();
    }
}