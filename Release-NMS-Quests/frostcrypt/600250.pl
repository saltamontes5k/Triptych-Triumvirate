# Wulfnor the Gladiator - Frostcrypt raid 2 (NPC 600250)
# Arena event; his fans encourage him and arena beasts are summoned (flavor).

sub EVENT_SPAWN {
  quest::setnexthpevent(85);
}

sub EVENT_AGGRO {
  quest::shout("Fans, witness me! This is my arena!");
  $npc->SetSpecialAttacks("rampage,flurry");
}

sub EVENT_HP {
  if ($hpevent == 85) {
    quest::shout("Beasts, tear them apart!");
    for (my $i = 0; $i < 3; $i++) {
      my $x = $npc->GetX() + int(rand(80)) - 40;
      my $y = $npc->GetY() + int(rand(80)) - 40;
      quest::spawn2(600254, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(50);
  }
  elsif ($hpevent == 50) {
    quest::shout("Putrid Cloud! Sword Flash! You will not best me!");
    for (my $i = 0; $i < 2; $i++) {
      my $x = $npc->GetX() + int(rand(80)) - 40;
      my $y = $npc->GetY() + int(rand(80)) - 40;
      quest::spawn2(600254, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    quest::shout("The arena is mine!");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Wulfnor the Gladiator sinks to one knee, and the arena falls silent.");
}
