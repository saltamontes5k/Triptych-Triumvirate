# an_angry_shade - Frostcrypt raid 1 (NPC 600233) - single rampage.

sub EVENT_AGGRO {
  quest::shout("We were told to meditate... we were not told to forgive!");
  $npc->SetSpecialAttacks("rampage");
}
