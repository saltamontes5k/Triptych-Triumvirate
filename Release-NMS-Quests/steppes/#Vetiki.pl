# Vetiki - The Steppes
# The Serpent's Spine :: Portal of War raid event, phase 2.
# Splits into lesser copies at 90, 80, 50, 35 and 20 percent.

sub EVENT_SPAWN {
  quest::emote("emerges wreathed in the smoke of the portal, and the smoke takes shapes of its own!");
  quest::setnexthpevent(90);
}

sub EVENT_HP {
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::emote("splits, and a lesser copy tears itself free of his shadow!");
  quest::spawn2(399131, 0, 0, $x + int(rand(80)) - 40, $y + int(rand(80)) - 40, $z, 0);
  if ($hpevent == 90) { quest::setnexthpevent(80); }
  elsif ($hpevent == 80) { quest::setnexthpevent(50); }
  elsif ($hpevent == 50) { quest::setnexthpevent(35); }
  elsif ($hpevent == 35) { quest::setnexthpevent(20); }
}

sub EVENT_DEATH {
  quest::ze(15, "Vetiki's copies collapse with him. The portal howls - Vegeroth is coming!");
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::unique_spawn(1120002374, 0, 0, $x, $y, $z, 0);
  for (1 .. 5) {{
    quest::spawn2(399131, 0, 0, $x + int(rand(120)) - 60, $y + int(rand(120)) - 60, $z, 0);
  }}
}
