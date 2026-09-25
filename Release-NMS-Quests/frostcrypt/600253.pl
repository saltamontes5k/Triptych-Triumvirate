# Beltron the Shade King - Frostcrypt raid 2 finale (NPC 600253)

sub EVENT_SPAWN {
  quest::setnexthpevent(70);
}

sub EVENT_AGGRO {
  quest::shout("Guards! Come deal with these pests!");
  $npc->SetSpecialAttacks("rampage");
}

sub EVENT_HP {
  if ($hpevent == 70) {
    quest::shout("The chaos begins. Shadow guardians, rise and take the corners!");
    for (my $i = 0; $i < 3; $i++) {
      my $x = $npc->GetX() + int(rand(90)) - 45;
      my $y = $npc->GetY() + int(rand(90)) - 45;
      quest::spawn2(600257, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(40);
  }
  elsif ($hpevent == 40) {
    quest::shout("You are strong. But the Shade King does not die.");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Beltron the Shade King is no more. Frostcrypt's throne stands empty.");
}
