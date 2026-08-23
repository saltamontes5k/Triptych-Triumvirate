sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello $name! I can disenchant a piece of Apocryphal or Rose Colored for you, returning it to it's original state. Alas, I cannot restore any items which I have disenchanted!");

  }  
}

sub EVENT_ITEM {
  if (!$client->GetGM()) {
    quest::say("I cannot disenchant items right now.");
    plugin::return_items(\%itemcount);
  }    
}
