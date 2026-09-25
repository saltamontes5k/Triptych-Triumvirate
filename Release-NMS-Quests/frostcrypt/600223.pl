# Hufdan - Frostcrypt raid 1 "Three Brothers" (NPC 600223)
# Sequential swap event: first aggro -> the hall faces Hufdan alone.
# Hufdan 20% -> Thuruld; Thuruld 20% -> Haevnar; Haevnar 70% -> all three at 40%.

sub EVENT_SPAWN {
  quest::setnexthpevent(20);
}

sub EVENT_AGGRO {
  if (!$npc->GetEntityVariable("chain")) {
    quest::depop(600222);
    quest::depop(600224);
    $npc->SetEntityVariable("chain", 1);
  }
  quest::shout("Another walks into our hall. Crush them!");
}

sub EVENT_HP {
  if ($hpevent == 20) {
    quest::shout("Thuruld! Finish what I started!");
    my $x = $npc->GetX(); my $y = $npc->GetY(); my $z = $npc->GetZ();
    quest::depop(600223);
    my $ent = quest::unique_spawn(600224, 0, 0, $x, $y, $z, 0);
    my $m = $entity_list->GetNPCByID($ent);
    if ($m) { $m->SetEntityVariable("chain", 1); }
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Hufdan has fallen...");
}
