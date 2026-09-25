# a_fuming_shade - Frostcrypt raid 1 (NPC 600232) - AE rampage, cures itself.

sub EVENT_AGGRO {
  quest::shout("The fury of the dead fumes within us!");
  $npc->SetSpecialAttacks("rampage");
}
