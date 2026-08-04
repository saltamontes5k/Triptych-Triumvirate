sub EVENT_SPAWN {
    quest::set_proximity($x - 200, $x + 200, $y - 88, $y + 88, $z - 50, $z + 50);
    quest::setnexthpevent(96);
    
   #my $roll = quest::ChooseRandom(1, 2, 3, 4, 5, 6, 7);
    
    #if    ($roll == 1) { $npc->AddItem(11608, 10); }
    #elsif ($roll == 2) { $npc->AddItem(11604); }
    #elsif ($roll == 3) { $npc->AddItem(11605, 1); }
    #elsif ($roll == 4) { $npc->AddItem(1011608, 50); }
    #elsif ($roll == 5) { $npc->AddItem(1011604); }
    #elsif ($roll == 6) { $npc->AddItem(2011608, 100); }
    #elsif ($roll == 7) { $npc->AddItem(2011604); }
}

sub EVENT_AGGRO {
    quest::settimer("leash", 1);
}

sub EVENT_HP {
    quest::stoptimer("leash");
    EVENT_AGGRO();
    quest::setnexthpevent(int($npc->GetHPRatio()) - 9);
}

sub EVENT_ENTER {
    if (($ulevel > 80) && ($status < 80)) {
        quest::echo(0, "I will not fight you, but I will banish you!");
        $client->MovePC(30, -7024, 2020, -60.7, 0);
    }
}

sub EVENT_TIMER {
    if ($timer eq "leash") {
        if ($x < -431 || $x > -85 || $y < 770 || $y > 1090 || $z < -50) {
            WIPE_AGGRO();
        }

        my @hate_list = $npc->GetHateList();
        if (scalar @hate_list > 0) {
            foreach my $ent (@hate_list) {
                my $h_ent = $ent->GetEnt();
                if ($h_ent->IsClient() && $h_ent->GetLevel() > 80) {
                    quest::ze(0, "I will not fight you, but I will banish you!");
                    $h_ent->CastToClient()->MovePC(30, -7024, 2020, -60.7, 0);
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