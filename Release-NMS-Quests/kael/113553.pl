# NPC for the plate cycle in Kael. The proximity and echo will need to be replaced when NPC listening to commands when not targeted is implemented.
sub EVENT_SPAWN {  
  $x = $npc->GetX();
  $y = $npc->GetY();
  $z = $npc->GetZ();
  quest::set_proximity($x - 30, $x + 30, $y - 30, $y +30, -999999, 999999, 1);
  quest::enable_proximity_say();
}

sub EVENT_PROXIMITY_SAY {
  my $last_spawn = $npc->GetEntityVariable("Doldigun_Spawn");
  if($last_spawn == "") {
    $last_spawn = 0;
  }

  if($text=~/dain/i && time - $last_spawn >= 600) {
    quest::unique_spawn(113440,0,0,1126.4,-840.6,-118.3,125.2); #Doldigun, non-loot version
    $npc->SetEntityVariable("Doldigun_Spawn", time);
  }
}

sub EVENT_SIGNAL {
  if ($dwarf == 1) {
    quest::spawn2(113508,31,0,1126,-840,-118.3,126.8); # NPC: #Doldigun_Steinwielder
    $dwarf = 0
  }
  elsif ($dwarf != 1) {
    $dwarf = 1;
  }
}
