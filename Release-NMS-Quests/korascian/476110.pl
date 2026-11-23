# Ylatra the Vassal (476110) -- Rathe chain givers + Murdunk mission (v466).
sub EVENT_SAY {
    plugin::SodTaskGiver($client, 476110, $text);
    plugin::SodMissionGiver($client, 304114, $text);
}
