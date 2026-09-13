# Kellak the Serpent Lord - Vergalid Mines (TSS instanced raid, Leviathan's Lair)
# npc: 600140   offspring: 600141   dz template: 6006 (vergalid version 1)
# Rooted in place in the water; spawns three rootable offspring on engage.

sub EVENT_AGGRO {
  quest::shout("Ssstudentssss... come and feed.");
  quest::emote("rears up, water churning around its coils, and calls to its brood.");
  for (my $i = 0; $i < 3; $i++) {
    my $ang = $i * 120;
    my $x = $npc->GetX() + int(50 * cos($ang * 3.14159 / 180));
    my $y = $npc->GetY() + int(50 * sin($ang * 3.14159 / 180));
    quest::spawn2(600141, 0, 0, $x, $y, $npc->GetZ(), 0);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Kellak the Serpent Lord thrashes once and sinks beneath the black water.");
}
