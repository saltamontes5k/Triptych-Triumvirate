sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(2);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hey, $name! What's that? You want a spot by the fire... well hop in Discord to find out how!");
  }  
}