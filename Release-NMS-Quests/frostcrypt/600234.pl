# a_glaring_shade - Frostcrypt raid 1 (NPC 600234) - flurries.

sub EVENT_AGGRO {
  quest::shout("Cold eyes upon you, warm thing.");
  $npc->SetSpecialAttacks("flurry");
}
