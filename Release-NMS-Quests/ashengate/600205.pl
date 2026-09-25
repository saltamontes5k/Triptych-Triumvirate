# Pyrachnid - Ashengate East raid (NPC 600205)
# Stitch's spider. Flurries and rampages.

sub EVENT_AGGRO {
  quest::emote("clicks its mandibles and lunges.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Pyrachnid curls up and is still.");
  quest::emote("a wave of searing heat washes over the chamber.");
}
