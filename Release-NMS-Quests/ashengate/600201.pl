# Griffon Master Ayna`Rym - Ashengate East raid (NPC 600201)
# Mini-boss (skippable). Two griffon sentries are spawned via the encounter SQL.

sub EVENT_AGGRO {
  quest::shout("The skies of Ashengate belong to me, little one!");
  quest::emote("shrieks, and her griffon sentries wheel into the air.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Griffon Master Ayna`Rym falls, her winds at last becalmed.");
}
