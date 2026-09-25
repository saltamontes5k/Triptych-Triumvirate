# a shadow in the mist - Sunderock Springs (Mistwalker add)
# Summoned once a minute; fades away after ten seconds.

sub EVENT_SPAWN {
  quest::settimer("fade", 10);
}

sub EVENT_TIMER {
  if ($timer eq "fade") {
    quest::depop();
  }
}
