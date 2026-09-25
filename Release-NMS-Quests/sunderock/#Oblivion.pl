# Oblivion - Sunderock Springs (raid event)
# Casts Slime (9449): a one-minute root, silence, and slime illusion, on
# multiple targets. At regular intervals it sheds 5-10 "an unstable clone"
# adds that detonate after a short fuse unless they are killed or mezzed.

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::settimer("clone", 60);
  }
  else {
    quest::stoptimer("clone");
  }
}

sub EVENT_TIMER {
  if ($timer eq "clone") {
    my $n = 5 + int(rand(6));   # 5..10
    for (my $i = 0; $i < $n; $i++) {
      my $x = $npc->GetX() + int(rand(81)) - 40;
      my $y = $npc->GetY() + int(rand(81)) - 40;
      quest::spawn2(600267, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::emote("shudders and sheds unstable clones of itself!");
  }
}
