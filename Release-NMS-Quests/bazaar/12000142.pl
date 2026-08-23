sub EVENT_SAY {
    if ($text =~ /Hail/i)
    {
    plugin::Whisper("Hello $name! Would you like to [Return to your bind]?");
    }
    if ($text =~ /Return to your bind/i)
    {
    $client->MovePC($client->GetBindZoneID, $client->GetBindX, $client->GetBindY, $client->GetBindZ, $client->GetBindHeading);
    }
}
