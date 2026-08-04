# Arx Fortis Override

sub EVENT_SPELL_EFFECT_CLIENT {
    if ($zoneid != 159) {
        $client->Message(289, "This may only be used inside Sanctus Seru.");
        return 1;
    } else {
        $client->MovePCInstance($zoneid, $instanceid, -231, -290, 60, 267);
        return 1;
    }
    return 1;
}