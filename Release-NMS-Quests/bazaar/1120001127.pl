sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
    if($text=~/hail/i) {
        quest::say("Hey, $name! Sorry for bringing the server down, but it's back up now, and that's all that matters, right?!");
    }
}