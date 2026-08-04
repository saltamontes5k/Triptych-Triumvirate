sub EVENT_SAY { 
    if ($text =~ /Hail/i) {
        quest::say("Hello $name. I do not have much time to chat. I must concentrate on maintaining the portal that is due to open soon. If you wish to [journey to Luclin], tell me so."); 
    }

    if ($text =~ /journey to Luclin/i && plugin::is_eligible_for_zone($client, 'nexus', 1)) {
        $client->MovePC(152, quest::GetZoneSafeX(152), quest::GetZoneSafeY(152), quest::GetZoneSafeZ(152), quest::GetZoneSafeHeading(152));
    }
}
