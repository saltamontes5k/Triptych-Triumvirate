# Fiddleback - Sunderock Springs (raid event)
# Giant spider. Weblash (9256) is a hatelist root + AC debuff; Mindfire Poison
# (9257) is a hatelist DoT, mana drain, and silence. Both fire on timers.

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::settimer("weblash", 30);
    quest::settimer("mindfire", 45);
  }
  else {
    quest::stoptimer("weblash");
    quest::stoptimer("mindfire");
  }
}

sub EVENT_TIMER {
  if ($timer eq "weblash") {
    my $t = $npc->GetHateTop();
    $npc->SpellFinished(9256, $t) if $t;
  }
  elsif ($timer eq "mindfire") {
    my $t = $npc->GetHateRandom();
    $npc->SpellFinished(9257, $t) if $t;
  }
}
