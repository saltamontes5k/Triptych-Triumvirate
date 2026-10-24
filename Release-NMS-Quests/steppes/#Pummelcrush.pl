# Pummelcrush - The Steppes
# The Serpent's Spine :: Portal of War raid event, phase 1.

sub EVENT_SPAWN {
  quest::emote("steps through the portal, shaking the ground with every stride!");
  quest::say("PUMMEL! CRUSH! PUMMELCRUSH SMASH LITTLE THINGS!");
}

sub EVENT_DEATH {
  quest::ze(15, "Pummelcrush falls - and a colder shapes steps through the portal behind him!");
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::unique_spawn(1120002373, 0, 0, $x, $y, $z, 0);
  for (1 .. 5) {{
    quest::spawn2(399131, 0, 0, $x + int(rand(120)) - 60, $y + int(rand(120)) - 60, $z, 0);
  }}
}
