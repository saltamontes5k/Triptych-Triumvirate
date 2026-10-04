# SoD progression: Korafax access gate (all 4 group chains or all 4 raid chains).
sub EVENT_ENTERZONE {
    plugin::SodGateKorafax($client);
}

