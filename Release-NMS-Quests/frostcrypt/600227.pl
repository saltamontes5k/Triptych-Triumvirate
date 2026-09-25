# Gravelord Cotas - Frostcrypt raid 1 "Overwhelming Numbers" (NPC 600227)
# Boss of the zombie-wave event. His death stops the waves (signals 600242).

sub EVENT_AGGRO {
  quest::shout("WHO DISTURBS THE GRAVES OF MY FLOCK?");
  $npc->SetSpecialAttacks("flurry");
}

sub EVENT_DEATH_COMPLETE {
  quest::signal(600242, 0);
}
