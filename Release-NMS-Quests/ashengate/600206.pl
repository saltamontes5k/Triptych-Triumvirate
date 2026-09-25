# Sothgar the Twiceborn - Ashengate West raid (NPC 600206)
# Started by saying "Awaken" to him; phases at 75/50/25 spawn oozes and drakes.

sub EVENT_SPAWN {
  quest::setnexthpevent(75);
}

sub EVENT_SAY {
  if ($text=~/awaken/i) {
    quest::shout("Awaken? I have never slept, little mortal.");
    quest::emote("rises from the lava, and the chamber trembles.");
    $npc->SetSpecialAttacks("silence");
  }
}

sub EVENT_AGGRO {
  quest::shout("You dare disturb the Twiceborn?");
}

sub EVENT_HP {
  if ($hpevent == 75) {
    quest::shout("The oozes come. Dance for me!");
    quest::setnexthpevent(50);
  }
  elsif ($hpevent == 50) {
    quest::shout("Again they rise. Do not fall in the lava!");
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    quest::shout("You have earned my full fury!");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Sothgar the Twiceborn is undone.");
}
