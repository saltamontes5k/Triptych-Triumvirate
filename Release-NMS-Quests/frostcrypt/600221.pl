# Lorekeeper Griswald - Frostcrypt raid 1 (NPC 600221)
# Summons 10 crypt zombies on aggro, re-raises one every 22s; at 75% raises
# Frostslash, at 50% Icegrind, at 25% two Frostcrypt alchemists.

sub EVENT_SPAWN {
  quest::setnexthpevent(75);
}

sub EVENT_AGGRO {
  quest::shout("Rise, my children! Rise and defend the lore!");
  $npc->SetSpecialAttacks("flurry,rampage");
  $npc->SetEntityVariable("rezzed", 0);
  for my $i (0 .. 9) {
    my $a = 0.6283 * $i;
    quest::spawn2(600225, 0, 0,
      $npc->GetX() + int(60 * sin($a)),
      $npc->GetY() + int(60 * cos($a)),
      $npc->GetZ(), 0);
  }
  quest::settimer("rez", 22);
}

sub EVENT_TIMER {
  if ($timer eq "rez") {
    quest::settimer("rez", 22);
    return if !$npc->IsEngaged();
    my $r = $npc->GetEntityVariable("rezzed") || 0;
    return if $r >= 10;
    quest::spawn2(600225, 0, 0,
      $npc->GetX() + int(rand(70)) - 35,
      $npc->GetY() + int(rand(70)) - 35,
      $npc->GetZ(), 0);
    $npc->SetEntityVariable("rezzed", $r + 1);
  }
}

sub EVENT_HP {
  if ($hpevent == 75) {
    quest::shout("Frostslash, to me!");
    quest::unique_spawn(600239, 0, 0,
      $npc->GetX() + 30, $npc->GetY() + 10, $npc->GetZ(), 0);
    quest::setnexthpevent(50);
  }
  elsif ($hpevent == 50) {
    quest::shout("Icegrind, rise again!");
    quest::unique_spawn(600238, 0, 0,
      $npc->GetX() - 30, $npc->GetY() + 10, $npc->GetZ(), 0);
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    quest::shout("Alchemists! Brew their doom!");
    quest::spawn2(600240, 0, 0,
      $npc->GetX() + 25, $npc->GetY() - 25, $npc->GetZ(), 0);
    quest::spawn2(600240, 0, 0,
      $npc->GetX() - 25, $npc->GetY() - 25, $npc->GetZ(), 0);
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Lorekeeper Griswald is undone. Frostcrypt mourns.");
}
