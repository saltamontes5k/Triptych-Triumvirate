# Mirrormask - Sunderock Springs (rare)
# Summons short-lived "a dark venom reflection" pets during the fight. They can
# be snared or rooted but are immune to mez, and despawn on their own.

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::settimer("reflect", 45);
  }
  else {
    quest::stoptimer("reflect");
  }
}

sub EVENT_TIMER {
  if ($timer eq "reflect") {
    for (my $i = 0; $i < 2; $i++) {
      my $x = $npc->GetX() + int(30 * cos($i * 3.14159));
      my $y = $npc->GetY() + int(30 * sin($i * 3.14159));
      quest::spawn2(600269, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::emote("gazes into the dark water, and venomous reflections rise to its defense.");
  }
}
