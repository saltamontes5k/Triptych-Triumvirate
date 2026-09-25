# Frostslash - Frostcrypt raid 1 (NPC 600239) - flurries.

sub EVENT_AGGRO {
  quest::shout("Frost to slash, slash to frost!");
  $npc->SetSpecialAttacks("flurry");
}
