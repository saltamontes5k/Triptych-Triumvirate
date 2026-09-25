# a dark venom reflection - Sunderock Springs (Mirrormask add)
# Short-lived duplicates summoned by Mirrormask. They can be snared or rooted
# but are immune to mez, and despawn on their own.

sub EVENT_SPAWN {
  quest::settimer("fade", 60);
}

sub EVENT_TIMER {
  if ($timer eq "fade") {
    quest::depop();
  }
}
