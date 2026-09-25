# Thulagar - Frostcrypt raid 1 "Shadow Selves" (NPC 600236)
# AE rampage; every 20s summons a doppleganger that mirrors raid members.
# Clones persist after his death.

sub EVENT_SPAWN {
  quest::setnexthpevent(50);
  $npc->SetEntityVariable("clones", 0);
}

sub EVENT_AGGRO {
  quest::shout("You carry your shadows with you. Let them serve ME.");
  $npc->SetSpecialAttacks("rampage");
  quest::settimer("dopple", 20);
}

sub EVENT_TIMER {
  if ($timer eq "dopple") {
    quest::settimer("dopple", 20);
    return if !$npc->IsEngaged();
    my $c = $npc->GetEntityVariable("clones") || 0;
    return if $c >= 10;
    quest::spawn2(600237, 0, 0,
      $npc->GetX() + int(rand(80)) - 40,
      $npc->GetY() + int(rand(80)) - 40,
      $npc->GetZ(), 0);
    $npc->SetEntityVariable("clones", $c + 1);
  }
}

sub EVENT_HP {
  if ($hpevent == 50) {
    quest::shout("Shadows, TAKE FORM!");
    quest::spawn2(600237, 0, 0,
      $npc->GetX() + 30, $npc->GetY() + 20, $npc->GetZ(), 0);
    quest::spawn2(600237, 0, 0,
      $npc->GetX() - 30, $npc->GetY() - 20, $npc->GetZ(), 0);
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Thulagar's shadow is cast no more.");
}
