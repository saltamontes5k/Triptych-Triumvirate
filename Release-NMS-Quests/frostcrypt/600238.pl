# Icegrind - Frostcrypt raid 1 (NPC 600238) - single target rampage.

sub EVENT_AGGRO {
  quest::shout("The grind of ice upon bone!");
  $npc->SetSpecialAttacks("rampage");
}
