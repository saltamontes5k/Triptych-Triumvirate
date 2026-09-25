# Fridleif, Master Warcraft - Frostcrypt raid 2 (NPC 600251)
# Summons reanimated Krithgor soldiers at 70/40 (flavor).

sub EVENT_SPAWN {
  quest::setnexthpevent(70);
}

sub EVENT_AGGRO {
  quest::shout("Wake up, you lazy rot bags! This fight isn't over!");
  $npc->SetSpecialAttacks("rampage,flurry");
}

sub EVENT_HP {
  if ($hpevent == 70) {
    quest::shout("You there! After those magic users!");
    for (my $i = 0; $i < 6; $i++) {
      my $x = $npc->GetX() + int(rand(100)) - 50;
      my $y = $npc->GetY() + int(rand(100)) - 50;
      quest::spawn2(600255, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(40);
  }
  elsif ($hpevent == 40) {
    quest::shout("Slices a hand through the air, and the ranks of the dead surge forward.");
    for (my $i = 0; $i < 6; $i++) {
      my $x = $npc->GetX() + int(rand(100)) - 50;
      my $y = $npc->GetY() + int(rand(100)) - 50;
      quest::spawn2(600255, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Fridleif, Master Warcraft, has fallen. The dead lie still.");
}
