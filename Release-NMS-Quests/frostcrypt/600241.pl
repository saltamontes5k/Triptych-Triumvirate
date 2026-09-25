# a_gargoyle_trapmaster - Frostcrypt raid 1 (NPC 600241)
# Roams Hearol's wing laying traps; flurries hard once engaged.

sub EVENT_AGGRO {
  quest::shout("The traps are set. Walk into them, meat.");
  $npc->SetSpecialAttacks("flurry");
}
