# a trapped Wraithguard - Icefall Glacier
# The Serpent's Spine :: Avalanche raid event
# Hail and say "help" to trigger. Waves of ice and Frostbite raiders close in;
# when they fall, Avalanche erupts. 1120002371 = #Avalanche

sub EVENT_SAY {
  if ($text=~/help/i) {
    my $state = quest::get_data('icefall_avalanche_event');
    if ($state >= 1) {
      quest::say("The ice itself rises against me! Break it, quickly!");
      return 1;
    }
    quest::say("A Wraithguard of Valdeholm, caught in the frozen snare of this place. If you would [" . quest::saylink("free me") . "], stand fast - the cold will not let me go quietly.");
    quest::set_data('icefall_avalanche_event', '1', '3600');
    quest::emote("gasps as the ice around him begins to move of its own accord!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    foreach my $id (400230, 400230, 400230) {
      quest::spawn2($id, 0, 0, $x + int(rand(50)) - 25, $y + int(rand(50)) - 25, $z, 0);
    }
    quest::settimer('aval_wave2', 25);
  }
}

sub EVENT_TIMER {
  my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
  if ($timer eq 'aval_wave2') {
    quest::stoptimer('aval_wave2');
    quest::emote("wrenches one arm free as more ice constructs tear loose!");
    foreach my $id (400230, 400230, 400230, 400212, 400212) {
      quest::spawn2($id, 0, 0, $x + int(rand(60)) - 30, $y + int(rand(60)) - 30, $z, 0);
    }
    quest::settimer('aval_wave3', 30);
  }
  if ($timer eq 'aval_wave3') {
    quest::stoptimer('aval_wave3');
    quest::emote("shouts in triumph - but the glacier itself answers!");
    foreach my $id (400230, 400230, 400194, 400194, 400233) {
      quest::spawn2($id, 0, 0, $x + int(rand(70)) - 35, $y + int(rand(70)) - 35, $z, 0);
    }
    quest::settimer('aval_boss', 30);
  }
  if ($timer eq 'aval_boss') {
    quest::stoptimer('aval_boss');
    quest::set_data('icefall_avalanche_event', '2', '14400');
    quest::ze(15, "Avalanche thunders loose from the glacier wall!");
    quest::unique_spawn(1120002371, 0, 0, $x + 50, $y, $z, 0);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
