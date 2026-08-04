sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
    if($text=~/hail/i) {
        quest::say("Mahalo, $name. Hope you like it here! Take a seat by the fire and stay a while.");
    }
}