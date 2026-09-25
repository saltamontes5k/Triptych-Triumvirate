# Lorekeeper Bentolf - Frostcrypt raid 1 "Shades of Calm" (NPC 600231)
# Tell him "we won't be quiet" to start the fight. Rooted in place; wakes
# shades one by one; at 50% swaps his defense profile. Shades die with him.

sub EVENT_SPAWN {
  quest::setnexthpevent(50);
  $npc->SetEntityVariable("wakes", 0);
}

sub EVENT_SAY {
  if ($text =~ /we won.?t be quiet/i) {
    quest::say("Then perish in your arrogance, intruders!");
    quest::shout("Blasphemers! Shades of the crypt, SILENCE THEM!");
    $npc->SetSpecialAttacks("flurry");
    $npc->AddToHateList($client, 10000, 0);
    quest::settimer("wakeshade", 15);
  }
}

sub EVENT_TIMER {
  if ($timer eq "wakeshade") {
    quest::settimer("wakeshade", 15);
    return if !$npc->IsEngaged();
    my $wakes = $npc->GetEntityVariable("wakes") || 0;
    return if $wakes >= 8;
    my @types = (600232, 600233, 600234, 600235, 600232, 600233, 600234, 600235);
    quest::spawn2($types[$wakes], 0, 0,
      $npc->GetX() + int(rand(70)) - 35,
      $npc->GetY() + int(rand(70)) - 35,
      $npc->GetZ(), 0);
    $npc->SetEntityVariable("wakes", $wakes + 1);
  }
}

sub EVENT_HP {
  if ($hpevent == 50) {
    quest::shout("My flesh fails... but my will hardens! Come, finish it!");
    $npc->SetSpecialAttacks("rampage,flurry");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::depop(600232);
  quest::depop(600233);
  quest::depop(600234);
  quest::depop(600235);
  quest::shout("Bentolf's meditation ends... forever.");
}
