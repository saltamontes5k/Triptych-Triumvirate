sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Greetings, $name! Thank you for being here! If you are enjoying your time, please consider joining us in Discord! More information about the server can be found at RetributionEQ.com!");
  }  
}