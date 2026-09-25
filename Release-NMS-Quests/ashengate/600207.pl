# an attendant of Sothgar - Ashengate West raid (NPC 600207)
# Five are rooted in place in the attendants' room; kill shortest -> tallest.

sub EVENT_AGGRO {
  quest::emote("strains against the runes binding it in place.");
}

sub EVENT_DEATH_COMPLETE {
  quest::emote("cracks apart, its aura fading.");
}
