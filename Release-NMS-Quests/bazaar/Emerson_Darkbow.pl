sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail Hero! I am Emerson Darkbow, Innoruuk's favored Ranger from Nektulous Forest. May the wind be always at your back!");
  }  
}