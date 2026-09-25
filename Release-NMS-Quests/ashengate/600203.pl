# Krait the Bloodletter - Ashengate East raid (NPC 600203)
# Spawns at the end of Stitch's Ambush.

sub EVENT_AGGRO {
  quest::shout("The ambush was only the beginning!");
  quest::emote("carves a bloody arc through the air.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Krait the Bloodletter collapses; the ambush is broken.");
}
