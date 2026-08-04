sub EVENT_SPAWN {
    $x = $npc->GetX();
    $y = $npc->GetY();
    $z = $npc->GetZ();

    quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {    
    my $limit = $client->GetBucket("waypoint_rate_limit") | "";

    if ($limit) {
        return;
    }

    if ($client->UnlockWaypoint($zonesn)) {
        $client->Message(263, "This place seems familiar. You are sure to remember it later.");
    } else {
        $client->Message(263, "You know this place well.");
    }

    $client->SetBucket("waypoint_rate_limit", "true", "60s");
}