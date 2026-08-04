sub EVENT_SPAWN {
    quest::set_proximity($x - 200, $x + 200, $y - 200, $y + 200, $z - 200, $z + 200, 0);
    quest::setnexthpevent(96);
}

sub EVENT_AGGRO {
    quest::settimer("leash", 1);
}

sub EVENT_HP {
    quest::stoptimer("leash");
    EVENT_AGGRO();
    quest::setnexthpevent(int($npc->GetHPRatio()) - 9);
}

sub EVENT_TIMER {
    if ($timer eq "leash") {
        if ($x < -1000 || $x > -650 || $y < -1500 || $y > -1290) {
            WIPE_AGGRO();
        }
        my @hate_list = $npc->GetHateList();
        if (@hate_list > 0) {
            foreach my $ent (@hate_list) {
                my $h_ent = $ent->GetEnt();
                if ($h_ent->IsClient() && $h_ent->GetLevel() > 80) {
                    quest::ze(0, "I will not fight you, but I will banish you!");
                    $h_ent->CastToClient()->MovePC(27, -64, 262, -93.96, 0);
                }
            }
        } else {
            WIPE_AGGRO();
        }
    }
}

sub WIPE_AGGRO {
    $npc->BuffFadeAll();
    $npc->WipeHateList();
    $npc->SetHP($npc->GetMaxHP());
    $npc->GMMove($npc->GetSpawnPointX(), $npc->GetSpawnPointY(), $npc->GetSpawnPointZ(), $npc->GetSpawnPointH());
    quest::stoptimer("leash");
    quest::setnexthpevent(96);
}

sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);

    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && int(rand(100)) == 0) {
        plugin::AddTitleFlag(200);
    }
}