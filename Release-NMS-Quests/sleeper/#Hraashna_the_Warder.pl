sub EVENT_DEATH_COMPLETE {
    quest::shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!");

    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && int(rand(500)) == 0) {
        plugin::AddTitleFlag(200);
    }
}