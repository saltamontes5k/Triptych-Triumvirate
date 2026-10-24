# Vegeroth - The Steppes
# The Serpent's Spine :: Portal of War raid event, phase 3.

sub EVENT_SPAWN {
  quest::emote("arrives wreathed in a wave of death that curls off him like fog!");
  quest::say("ALL THINGS END. YOU END NOW.");
}

sub EVENT_DEATH {
  quest::ze(15, "Vegeroth crumbles. Two titanic constructs take his place!");
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::unique_spawn(1120002375, 0, 0, $x + 60, $y, $z, 0);
  quest::unique_spawn(1120002376, 0, 0, $x - 60, $y, $z, 0);
}
