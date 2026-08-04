sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(3);
}

sub EVENT_SAY {
    if($text=~/hail/i) {
        quest::say("Oh, $name. What did I do to deserve this?");
    }
}