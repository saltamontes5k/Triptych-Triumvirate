# Ambersnout the Aberration - Ashengate West raid (NPC 999303)
# Mini-boss (skippable). Normally roused by breaking the egg beneath the bridge.

sub EVENT_AGGRO {
  quest::shout("The aberration stirs, wreathed in amber flame!");
  quest::emote("pads around the chamber; piles of ashen goo shudder and rise.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Ambersnout the Aberration collapses into slag.");
}
