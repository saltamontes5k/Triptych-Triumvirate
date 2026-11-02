# Severan the Direwind Caller - Direwind Cliffs
# The Serpent's Spine :: open-world raid event.
# Four elemental totems ring him (permarooted); he calls Direwind Gusts while
# engaged. Pull him from the totems at your peril - his regen is legendary.

sub EVENT_SPAWN {
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  quest::unique_spawn(1120002378, 0, 0, $x + 45, $y + 45, $z, 0); # Stormwind Totem
  quest::unique_spawn(1120002379, 0, 0, $x - 45, $y + 45, $z, 0); # Blightwind Totem
  quest::unique_spawn(1120002380, 0, 0, $x + 45, $y - 45, $z, 0); # Deathwind Totem
  quest::unique_spawn(1120002381, 0, 0, $x - 45, $y - 45, $z, 0); # Hatewind Totem
  quest::setnexthpevent(50);
}

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::settimer('severan_gusts', 60);
    quest::emote("raises his staff and the wind answers, howling in from four directions!");
  }
  else {
    quest::stoptimer('severan_gusts');
  }
}

sub EVENT_TIMER {
  if ($timer eq 'severan_gusts') {
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    my $n = 2 + int(rand(3));
    for (1 .. $n) {
      quest::spawn2(1120002382, 0, 0, $x + int(rand(80)) - 40, $y + int(rand(80)) - 40, $z, 0);
    }
  }
}

sub EVENT_HP {
  if ($hpevent == 50) {
    quest::emote("screaks, and four golems of blighted wind coalesce around him!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    for my $dx (-40, 40) {{
      quest::spawn2(1120002383, 0, 0, $x + $dx, $y, $z, 0);
    }}
  }
}

sub EVENT_DEATH {
  quest::stoptimer('severan_gusts');
  quest::depopall(1120002378);
  quest::depopall(1120002379);
  quest::depopall(1120002380);
  quest::depopall(1120002381);
  quest::depopall(1120002382);
  quest::ze(15, "With Severan's death the winds fall still, and the totems crumble to dust.");
}
