# fc1_wave_controller - Frostcrypt raid 1 "Overwhelming Numbers" (NPC 600242)
# Spawns zombie waves down the main hall every 60s; at wave 5 Gravelord Cotas
# rises. Cotas' death signals this controller to stop the waves.

sub EVENT_SPAWN {
  $npc->SetEntityVariable("waves", 0);
  quest::settimer("wave", 60);
}

sub EVENT_TIMER {
  return if $timer ne "wave";
  my $waves = $npc->GetEntityVariable("waves") || 0;
  if ($waves >= 12) {
    quest::stoptimer("wave");
    return;
  }
  my @types = (600228, 600229, 600230);
  for my $i (0 .. 6) {
    my $t = $types[int(rand(3))];
    quest::spawn2($t, 0, 0,
      $npc->GetX() + int(rand(70)) - 35,
      $npc->GetY() - 100 - int(rand(300)),
      $npc->GetZ(), 0);
  }
  $waves++;
  $npc->SetEntityVariable("waves", $waves);
  if ($waves == 5) {
    quest::unique_spawn(600227, 0, 0,
      $npc->GetX(), $npc->GetY() - 250, $npc->GetZ(), 0);
    quest::shout("Gravelord Cotas rises in the main hall!");
  }
  quest::settimer("wave", 60);
}

sub EVENT_SIGNAL {
  quest::stoptimer("wave");
  quest::shout("The halls fall silent... at last.");
}
