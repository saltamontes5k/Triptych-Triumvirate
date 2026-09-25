# Thuruld - Frostcrypt raid 1 "Three Brothers" (NPC 600224)
# Chain: Hufdan 20% -> Thuruld. Static-aggro fallback: face Hufdan first.

sub EVENT_SPAWN {
  quest::setnexthpevent(20);
}

sub EVENT_AGGRO {
  if (!$npc->GetEntityVariable("chain")) {
    my $x = $npc->GetX(); my $y = $npc->GetY(); my $z = $npc->GetZ();
    quest::depop(600222);
    quest::depop(600224);
    my $ent = quest::unique_spawn(600223, 0, 0, $x, $y, $z, 0);
    my $m = $entity_list->GetNPCByID($ent);
    if ($m) { $m->SetEntityVariable("chain", 1); }
    return;
  }
  quest::shout("Freeze where you stand!");
  $npc->SetSpecialAttacks("rampage");
}

sub EVENT_HP {
  if ($hpevent == 20) {
    quest::shout("The cold takes you... but the eldest still waits! Haevnar!");
    my $x = $npc->GetX(); my $y = $npc->GetY(); my $z = $npc->GetZ();
    quest::depop(600224);
    my $ent = quest::unique_spawn(600222, 0, 0, $x, $y, $z, 0);
    my $m = $entity_list->GetNPCByID($ent);
    if ($m) {
      $m->SetEntityVariable("chain", 1);
      $m->SetEntityVariable("final", 1);
      $m->SetNextHPEvent(70);
    }
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Thuruld is broken. The hall grows quiet.");
}
