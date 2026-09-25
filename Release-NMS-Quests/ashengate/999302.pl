# Lethar the Black - Ashengate North raid (NPC 999302)
# Rooted; phases at 75/50/25. Also appears in Lethar's Final Stand (Selay).

sub EVENT_SPAWN {
  quest::setnexthpevent(75);
}

sub EVENT_AGGRO {
  quest::shout("I am Lethar the Black. This reliquary is my grave and my throne!");
  quest::emote("unfurls her wings as drakes swarm into the hall.");
}

sub EVENT_HP {
  if ($hpevent == 75) {
    quest::shout("Enough! Face me deeper in!");
    quest::setnexthpevent(50);
  }
  elsif ($hpevent == 50) {
    quest::shout("The mirrorscale watches. Turn me not into its gaze!");
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    quest::shout("You will not see the end of me!");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Lethar the Black falls... but the mountain shudders.");
}
