# Hearol the Tactician - Frostcrypt raid 1 (NPC 600220)
# Phases at 80/60/40/20 (raspersrealm): giants pour in each phase and
# gargoyle trapmasters roam laying traps. Room-split walls omitted.

sub EVENT_SPAWN {
  quest::setnexthpevent(80);
}

sub EVENT_AGGRO {
  quest::shout("You should not have come. The ice will drink deep today.");
  $npc->SetSpecialAttacks("rampage,flurry");
  quest::spawn2(600241, 0, 0,
    $npc->GetX() - 50, $npc->GetY() - 50, $npc->GetZ(), 0);
}

sub EVENT_HP {
  if ($hpevent == 80) {
    quest::shout("Walls, rise! Let them be split and scattered!");
    spawn_giants(4);
    quest::setnexthpevent(60);
  }
  elsif ($hpevent == 60) {
    quest::shout("You fight well. It will not save you.");
    spawn_giants(4);
    quest::spawn2(600241, 0, 0,
      $npc->GetX() + 50, $npc->GetY() - 50, $npc->GetZ(), 0);
    quest::setnexthpevent(40);
  }
  elsif ($hpevent == 40) {
    quest::shout("I am the Tactician of Frostcrypt. You are nothing.");
    spawn_giants(4);
    quest::setnexthpevent(20);
  }
  elsif ($hpevent == 20) {
    quest::shout("This cannot be...!");
    spawn_giants(4);
    quest::spawn2(600241, 0, 0,
      $npc->GetX() + 50, $npc->GetY() + 50, $npc->GetZ(), 0);
    quest::setnexthpevent(-1);
  }
}

sub spawn_giants {
  my $n = shift;
  for (my $i = 0; $i < $n; $i++) {
    my $x = $npc->GetX() + int(rand(80)) - 40;
    my $y = $npc->GetY() + int(rand(80)) - 40;
    quest::spawn2(600226, 0, 0, $x, $y, $npc->GetZ(), 0);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Hearol the Tactician has fallen. The west wing is silent.");
}
