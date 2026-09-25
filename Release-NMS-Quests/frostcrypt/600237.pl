# Thulagar`s_Doppleganger - Frostcrypt raid 1 (NPC 600237)
# Mirror add: opens with Identity Crisis (DA) and flurries.

sub EVENT_SPAWN {
  quest::shout("A shadow takes form!");
  $npc->CastSpell(7229, $npc->GetID());
}

sub EVENT_AGGRO {
  $npc->SetSpecialAttacks("flurry");
}
