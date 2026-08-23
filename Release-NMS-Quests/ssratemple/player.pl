sub EVENT_CLICKDOOR {
    if ($doorid == 54 && plugin::check_hasitem($client, 19719)) {
        $client->KeyRingAdd(19719);
        return 0;
    }
    if ($doorid == 54 && $client->KeyRingCheck(19719)) {
        $client->MovePCInstance($zoneid, $instanceid, 620, -324, 405, 126);
    }
}