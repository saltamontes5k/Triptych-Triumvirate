sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail Hero! Grandmaster Lozz and I are happy to be on New Multiclass Server with you! Safest of travels to you!");
  }  
}