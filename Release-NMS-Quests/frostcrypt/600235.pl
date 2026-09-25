# an_inconsolable_shade - Frostcrypt raid 1 (NPC 600235) - flurries.

sub EVENT_AGGRO {
  quest::shout("No silence will comfort us now - only your silence!");
  $npc->SetSpecialAttacks("flurry");
}
