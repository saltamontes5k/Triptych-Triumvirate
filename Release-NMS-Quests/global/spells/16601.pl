# Summon Clockwork Banker

sub EVENT_SPELL_EFFECT_CLIENT {

    # Generate randomized spawn coordinates within 5 units of the client's position
    my $spawn_x = $client->GetX() + (rand(10) - 5);
    my $spawn_y = $client->GetY() + (rand(10) - 5);
    my $spawn_z = $client->GetZ();
    my $heading = rand(520);

    my @mob_list = $entity_list->GetMobList();
    foreach my $m (@mob_list) {
        if ($m->GetNPCTypeID() == 772 && $m->GetEntityVariable("owner") == $client->CharacterID()) {
            $m->Depop();
        }
    }

    # Spawn the Clockwork Banker
    my $banker = quest::spawn2(772, 0, 0, $spawn_x, $spawn_y, $spawn_z, $heading);

    if ($banker) {
       my $banker_handle = $entity_list->GetMobByID($banker);

         if ($banker_handle) {
              $banker_handle->TempName($client->GetCleanName() . "'s Clockwork Banker");
              $banker_handle->SetEntityVariable("owner", $client->CharacterID());            
         }
    }

    return 1;
}
