# Diennic Lightheart (456060) -- Kithicor tasks + the two camp missions (v466).
sub EVENT_SAY {
    plugin::SodTaskGiver($client, 456060, $text);
    plugin::SodMissionGiver($client, 304115, $text);
    plugin::SodMissionGiver($client, 304116, $text);
}
