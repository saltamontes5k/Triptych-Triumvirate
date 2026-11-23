# Dan Hearthpride (467060) -- village tasks + The Undead Surge (v466).
sub EVENT_SAY {
    plugin::SodTaskGiver($client, 467060, $text);
    plugin::SodMissionGiver($client, 304118, $text);
}
