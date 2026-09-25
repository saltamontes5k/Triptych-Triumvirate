# Haevnar - Frostcrypt raid 1 "Three Brothers" (NPC 600222)
# Chain anchor of the final phase: at 70% (when spawned as "final") both
# brothers respawn at 40%. Casts Plague of Apathy after a time (flavor).

sub EVENT_SPAWN {
  if ($npc->GetEntityVariable("final")) {
    quest::setnexthpevent(70);
  }
  quest::settimer("checkhp", 3);
  quest::settimer("apathy", 60);
}

sub EVENT_TIMER {
  if ($timer eq "apathy" && $npc->IsEngaged()) {
    quest::stoptimer("apathy");
    quest::shout("Plague of Apathy, take them!");
  }
  elsif ($timer eq "checkhp") {
    quest::settimer("checkhp", 3);
    if ($npc->IsEngaged()
        && $npc->GetEntityVariable("final")
        && !$npc->GetEntityVariable("brothers_up")
        && $npc->GetHPRatio() <= 70) {
      $npc->SetEntityVariable("brothers_up", 1);
      quest::shout("Rise, brothers! The line is not broken!");
      foreach my $t (600223, 600224) {
        my $ent = quest::unique_spawn($t, 0, 0,
          $npc->GetX() + int(rand(70)) - 35,
          $npc->GetY() + int(rand(70)) - 35,
          $npc->GetZ(), 0);
        my $m = $entity_list->GetNPCByID($ent);
        if ($m) {
          $m->SetEntityVariable("chain", 1);
          $m->SetHP(int($m->GetMaxHP() * 0.4));
        }
      }
    }
  }
}

sub EVENT_AGGRO {
  if (!$npc->GetEntityVariable("chain")) {
    my $x = $npc->GetX(); my $y = $npc->GetY(); my $z = $npc->GetZ();
    quest::depop(600222);
    quest::depop(600223);
    quest::depop(600224);
    my $ent = quest::unique_spawn(600223, 0, 0, $x, $y, $z, 0);
    my $m = $entity_list->GetNPCByID($ent);
    if ($m) { $m->SetEntityVariable("chain", 1); }
    return;
  }
  quest::shout("Brothers! To arms! None shall pass!");
  $npc->SetSpecialAttacks("flurry");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Haevnar falls... the eldest is slain!");
}
