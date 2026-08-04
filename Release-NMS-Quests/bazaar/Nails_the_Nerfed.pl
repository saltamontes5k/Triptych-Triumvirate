sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(3);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail Hero! I remember when my fists were made of steel... and they latched on to these twigs with unmatched force!");
  }  
}