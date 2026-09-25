# an unstable clone - Sunderock Springs (Oblivion add)
# If not killed or mezzed within ~40 seconds it detonates in a burst of
# unresistable slime on everything around it.

sub EVENT_SPAWN {
  quest::settimer("detonate", 40);
}

sub EVENT_TIMER {
  if ($timer eq "detonate") {
    $npc->SpellFinished(4452, $npc);
    quest::depop();
  }
}
