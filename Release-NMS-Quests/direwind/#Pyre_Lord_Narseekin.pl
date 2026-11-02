# Pyre Lord Narseekin - Direwind Cliffs
# The Serpent's Spine :: open-world raid event.
# Two Blight Pyre Golems attend him; more erupt at 85, 50, 20 and 10 percent.

sub EVENT_SPAWN {
  quest::setnexthpevent(85);
}

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::emote("roars as two Blight Pyre Golems rise from the scorched ground!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    quest::spawn2(1120002383, 0, 0, $x + 50, $y, $z, 0);
    quest::spawn2(1120002383, 0, 0, $x - 50, $y, $z, 0);
  }
}

sub EVENT_HP {
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::emote("blisters the earth, and another Blight Pyre Golem claws its way free!");
  quest::spawn2(1120002383, 0, 0, $x + int(rand(80)) - 40, $y + int(rand(80)) - 40, $z, 0);
  if ($hpevent == 85) { quest::setnexthpevent(50); }
  elsif ($hpevent == 50) { quest::setnexthpevent(20); }
  elsif ($hpevent == 20) { quest::setnexthpevent(10); }
}

sub EVENT_DEATH {
  quest::depopall(1120002383);
  quest::ze(15, "Pyre Lord Narseekin collapses into ash and slag.");
}
