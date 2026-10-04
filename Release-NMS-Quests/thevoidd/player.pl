# SoD progression: The Void version gate (miscProgression rules).
sub EVENT_ENTERZONE {
    plugin::SodGateVoid($client, 'thevoidd');
}

