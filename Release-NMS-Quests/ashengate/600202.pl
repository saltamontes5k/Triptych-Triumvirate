# Stitch - Ashengate East raid (NPC 600202)
# First Born of Dyn`Leth. His spiders Cinderweb and Pyrachnid join the fight.

sub EVENT_SPAWN {
  quest::setnexthpevent(40);
}

sub EVENT_AGGRO {
  quest::shout("You should not have come to my web!");
  quest::emote("skitters forward as magmatic spiderlings boil up from the cracks.");
}

sub EVENT_HP {
  if ($hpevent == 40) {
    quest::shout("Cinderweb! Pyrachnid! To me!");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Stitch is torn apart, and the eastern wing falls silent.");
}
