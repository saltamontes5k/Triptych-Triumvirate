sub EVENT_ENTER_ZONE {
    if ($instanceversion == 0) {
        quest::debug(quest::GetInstanceID($zonesn, 1));
        $client->MovePCInstance($zoneid, quest::GetInstanceID($zonesn, 1), $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
    }    
}

sub EVENT_CONNECT {
    if ($instanceversion == 0) {
        quest::debug(quest::GetInstanceID($zonesn, 1));
        $client->MovePCInstance($zoneid, quest::GetInstanceID($zonesn, 1), $client->GetX(), $client->GetY(), $client->GetZ(), $client->GetHeading());
    }    
}