# Harfange the Black - Frostcrypt raid 2 (NPC 600252)
# Icy coffins line the walls; drops Fellwinter to unlock Beltron (flavor).

sub EVENT_SPAWN {
  quest::setnexthpevent(40);
}

sub EVENT_AGGRO {
  quest::shout("As Harfange calls to his guards sealed in the walls the icy coffins begin to open.");
  $npc->SetSpecialAttacks("rampage,flurry");
}

sub EVENT_HP {
  if ($hpevent == 40) {
    quest::shout("Seal the coffins! Now! Before they wake!");
    for (my $i = 0; $i < 4; $i++) {
      my $x = $npc->GetX() + int(rand(100)) - 50;
      my $y = $npc->GetY() + int(rand(100)) - 50;
      quest::spawn2(600256, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Harfange the Black is slain. Fellwinter clatters to the frozen floor.");
}
