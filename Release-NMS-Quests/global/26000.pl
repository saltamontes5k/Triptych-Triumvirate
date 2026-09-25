sub EVENT_SPAWN {
  quest::settimer(1, 1200);
  quest::settimer(2, 3); # deferred first-guild congrats; spawner sets entity vars after spawn
  quest::emote("rises from the corpse and stares around, as if waiting...");

  my $expedition = quest::get_expedition();
  if ($expedition && plugin::IsNMS()) {
    $expedition->SetLocked(1);
  }

  $npc->MoveTo($npc->GetX(), $npc->GetY(), $npc->FindGroundZ($npc->GetX(), $npc->GetY()));
}

sub EVENT_SAY {
    my $flag_stage = $npc->GetEntityVariable("Stage-Name");
    my $flag_name  = $npc->GetEntityVariable("Flag-Name");

    if ($flag_name eq "emperorssraeshza") { $flag_name = "emperor ssraeshza"}

    quest::debug("flag_stage: $flag_stage, flag_name: $flag_name");

    if ($text =~ /hail/i) {
        if (plugin::IsSeasonal($client) || plugin::MultiClassingEnabled()) {
            if (!plugin::ValidProgInstance($zoneid, $instanceid, $instanceversion)) {      
                plugin::YellowText("You may only advance your progression within an instance.");          
                return;
            }
        }  
        plugin::SetSubflag($client, $flag_stage, $flag_name);

        # Optional second flag pair (e.g. Tunat`Muram opens both OoW and DoD on one hail)
        my $flag_stage_2 = $npc->GetEntityVariable("Stage-Name-2");
        my $flag_name_2  = $npc->GetEntityVariable("Flag-Name-2");
        if (defined $flag_stage_2 && defined $flag_name_2 && $flag_stage_2 ne '' && $flag_name_2 ne '') {
            plugin::SetSubflag($client, $flag_stage_2, $flag_name_2);
        }

        quest::debug(". $flag_name . " . $client->IsTaskActivityActive(4, 6));

        if ($flag_name eq lc("Lord Nagafen") && $client->IsTaskActivityActive(4, 5)) {
            $client->UpdateTaskActivity(4, 5, 1);
        }

        if ($flag_name eq lc("Lady Vox") && $client->IsTaskActivityActive(4, 6)) {
            $client->UpdateTaskActivity(4, 6, 1);
        }
    }
}

sub EVENT_TIMER {
    if ($timer == 2) {
        quest::stoptimer(2);
        plugin::MemoryCongrats($npc);
        return;
    }

    quest::emote("vanishes.");
    quest::depop();
}
