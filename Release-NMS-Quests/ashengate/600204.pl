# Cinderweb - Ashengate East raid (NPC 600204)
# Stitch's spider. Death releases a searing burst.

sub EVENT_AGGRO {
  quest::emote("hisses, its legs glowing white-hot.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Cinderweb shudders and goes still.");
  quest::emote("a wave of searing heat washes over the chamber.");
}
