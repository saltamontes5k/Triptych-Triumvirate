sub EVENT_CLICKDOOR {
    if ($doorid == 146) { # Magic Map
        $client->SendWaypointList();
    }    
}