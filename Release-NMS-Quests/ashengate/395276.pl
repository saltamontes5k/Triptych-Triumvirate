# Selay the Cascade - Ashengate North raid (NPC 395276)
# Appears with Lethar during Lethar's Final Stand.

sub EVENT_AGGRO {
  quest::shout("You will not take him from me!");
  quest::emote("calls down a torrent from the shattered roof.");
}

sub EVENT_DEATH_COMPLETE {
  quest::emote("the cascade falls still.");
}
